// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief Small LLVM-C helpers that require target macros or typed metadata APIs.
 * @note LLVMInitializeAllTargetInfos/Targets/TargetMCs/AsmParsers/AsmPrinters
 *       are header macros — undeclarable as Nyra `@extern("C")`.
 * @see docs/design/compiler/nyra-llvm.md §1.5.1 · m_v0.6_p2 Record
 */

#include "llvm-c/Target.h"
#include "llvm-c/Core.h"
#include "llvm-c/DebugInfo.h"
#include "llvm-c/Comdat.h"
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

void nyra_llvm_initialize_all(void) {
  LLVMInitializeAllTargetInfos();
  LLVMInitializeAllTargets();
  LLVMInitializeAllTargetMCs();
  LLVMInitializeAllAsmParsers();
  LLVMInitializeAllAsmPrinters();
}

static void nyra_core_coff_comdat(LLVMModuleRef module, LLVMValueRef value) {
  LLVMLinkage linkage = LLVMGetLinkage(value);
  if (LLVMIsDeclaration(value) ||
      (linkage != LLVMLinkOnceODRLinkage && linkage != LLVMWeakODRLinkage)) return;
  size_t length = 0;
  const char *name = LLVMGetValueName2(value, &length);
  if (!length) return;
  LLVMComdatRef group = LLVMGetOrInsertComdat(module, name);
  LLVMSetComdatSelectionKind(group, LLVMAnyComdatSelectionKind);
  LLVMSetComdat(value, group);
}

/* COFF requires explicit section selection for cross-TU ownership/templates. */
void nyra_core_prepare_coff_comdats(LLVMModuleRef module) {
  for (LLVMValueRef value = LLVMGetFirstFunction(module); value; value = LLVMGetNextFunction(value))
    nyra_core_coff_comdat(module, value);
  for (LLVMValueRef value = LLVMGetFirstGlobal(module); value; value = LLVMGetNextGlobal(value))
    nyra_core_coff_comdat(module, value);
}

void nyra_core_add_debug_module_flags(LLVMModuleRef module) {
  LLVMSetIsNewDbgInfoFormat(module, 1);
  LLVMContextRef context = LLVMGetModuleContext(module);
  LLVMTypeRef i32 = LLVMInt32TypeInContext(context);
  LLVMAddModuleFlag(module, LLVMModuleFlagBehaviorWarning,
                    "Debug Info Version", sizeof("Debug Info Version") - 1,
                    LLVMValueAsMetadata(LLVMConstInt(i32, 3, 0)));
  LLVMAddModuleFlag(module, LLVMModuleFlagBehaviorWarning,
                    "Dwarf Version", sizeof("Dwarf Version") - 1,
                    LLVMValueAsMetadata(LLVMConstInt(i32, 4, 0)));
}

typedef struct NyraCoreDebugComposite {
  LLVMMetadataRef temporary;
  LLVMMetadataRef scope;
  LLVMMetadataRef file;
  char *name;
  size_t name_len;
  unsigned line;
  uint64_t size_bits;
  uint32_t align_bits;
  unsigned is_union;
  LLVMMetadataRef *elements;
  unsigned count;
  unsigned capacity;
  struct NyraCoreDebugComposite *next;
} NyraCoreDebugComposite;

/* Pending composites are owned by one emitter, never process-global. */

LLVMMetadataRef nyra_core_debug_basic_type(LLVMDIBuilderRef builder,
                                            const char *name, size_t name_len,
                                            uint64_t size_bits, unsigned encoding) {
  return LLVMDIBuilderCreateBasicType(builder, name, name_len, size_bits,
                                      (LLVMDWARFTypeEncoding)encoding, LLVMDIFlagZero);
}

LLVMMetadataRef nyra_core_debug_pointer_type(LLVMDIBuilderRef builder,
                                              LLVMMetadataRef base_type,
                                              const char *name, size_t name_len,
                                              uint64_t size_bits) {
  return LLVMDIBuilderCreatePointerType(builder, base_type, size_bits, 0, 0,
                                        name, name_len);
}

LLVMMetadataRef nyra_core_debug_function_pointer_type(LLVMDIBuilderRef builder,
                                                       LLVMMetadataRef file,
                                                       LLVMMetadataRef *parameter_types,
                                                       uint32_t parameter_count,
                                                       const char *name, size_t name_len,
                                                       uint64_t size_bits) {
  LLVMMetadataRef signature = LLVMDIBuilderCreateSubroutineType(
      builder, file, parameter_types, parameter_count, LLVMDIFlagZero);
  if (!signature) return NULL;
  return LLVMDIBuilderCreatePointerType(builder, signature, size_bits, 0, 0,
                                        name, name_len);
}

LLVMMetadataRef nyra_core_debug_array_type(LLVMDIBuilderRef builder,
                                            LLVMMetadataRef element_type,
                                            uint64_t size_bits, uint32_t align_bits,
                                            int64_t length) {
  LLVMMetadataRef subrange = LLVMDIBuilderGetOrCreateSubrange(builder, 0, length);
  LLVMMetadataRef subscripts[] = {subrange};
  return LLVMDIBuilderCreateArrayType(builder, size_bits, align_bits, element_type,
                                      subscripts, 1);
}

LLVMMetadataRef nyra_core_debug_composite_begin(LLVMDIBuilderRef builder,
                                                 LLVMMetadataRef scope,
                                                 LLVMMetadataRef file,
                                                 const char *name, size_t name_len,
                                                 unsigned line, uint64_t size_bits,
                                                 uint32_t align_bits, unsigned is_union, void **pending) {
  if (!pending) return NULL;
  NyraCoreDebugComposite *entry = calloc(1, sizeof(*entry));
  if (!entry) return NULL;
  entry->name = malloc(name_len + 1);
  if (!entry->name) { free(entry); return NULL; }
  memcpy(entry->name, name, name_len);
  entry->name[name_len] = '\0';
  entry->name_len = name_len;
  entry->scope = scope;
  entry->file = file;
  entry->line = line;
  entry->size_bits = size_bits;
  entry->align_bits = align_bits;
  entry->is_union = is_union;
  unsigned tag = is_union ? 0x17 : 0x13; /* DW_TAG_union_type / structure_type */
  entry->temporary = LLVMDIBuilderCreateReplaceableCompositeType(
      builder, tag, entry->name, entry->name_len, scope, file, line, 0,
      size_bits, align_bits, LLVMDIFlagZero, entry->name, entry->name_len);
  if (!entry->temporary) { free(entry->name); free(entry); return NULL; }
  entry->next = (NyraCoreDebugComposite *)*pending;
  *pending = entry;
  return entry->temporary;
}

unsigned nyra_core_debug_composite_member(LLVMDIBuilderRef builder,
                                           LLVMMetadataRef temporary,
                                           LLVMMetadataRef file,
                                           const char *name, size_t name_len,
                                           unsigned line, uint64_t size_bits,
                                           uint32_t align_bits, uint64_t offset_bits,
                                           LLVMMetadataRef type, void **pending) {
  if (!pending) return 0;
  NyraCoreDebugComposite *entry = (NyraCoreDebugComposite *)*pending;
  while (entry && entry->temporary != temporary) entry = entry->next;
  if (!entry || !type) return 0;
  LLVMMetadataRef member = LLVMDIBuilderCreateMemberType(
      builder, temporary, name, name_len, file, line, size_bits, align_bits,
      offset_bits, LLVMDIFlagZero, type);
  if (!member) return 0;
  if (entry->count == entry->capacity) {
    unsigned capacity = entry->capacity ? entry->capacity * 2 : 4;
    LLVMMetadataRef *elements = realloc(entry->elements, capacity * sizeof(*elements));
    if (!elements) return 0;
    entry->elements = elements;
    entry->capacity = capacity;
  }
  entry->elements[entry->count++] = member;
  return 1;
}

LLVMMetadataRef nyra_core_debug_composite_end(LLVMDIBuilderRef builder,
                                               LLVMMetadataRef temporary, void **pending) {
  if (!pending) return NULL;
  NyraCoreDebugComposite *head = (NyraCoreDebugComposite *)*pending;
  NyraCoreDebugComposite **link = &head;
  while (*link && (*link)->temporary != temporary) link = &(*link)->next;
  if (!*link) return NULL;
  NyraCoreDebugComposite *entry = *link;
  LLVMMetadataRef complete;
  if (entry->is_union) {
    complete = LLVMDIBuilderCreateUnionType(builder, entry->scope, entry->name,
        entry->name_len, entry->file, entry->line, entry->size_bits,
        entry->align_bits, LLVMDIFlagZero, entry->elements, entry->count, 0,
        entry->name, entry->name_len);
  } else {
    complete = LLVMDIBuilderCreateStructType(builder, entry->scope, entry->name,
        entry->name_len, entry->file, entry->line, entry->size_bits,
        entry->align_bits, LLVMDIFlagZero, NULL, entry->elements, entry->count,
        0, NULL, entry->name, entry->name_len);
  }
  if (complete) LLVMMetadataReplaceAllUsesWith(temporary, complete);
  *link = entry->next;
  *pending = head;
  free(entry->elements);
  free(entry->name);
  free(entry);
  return complete;
}

void nyra_core_debug_composite_discard_pending(void **pending) {
  if (!pending) return;
  while (*pending) {
    NyraCoreDebugComposite *entry = (NyraCoreDebugComposite *)*pending;
    *pending = entry->next;
    free(entry->elements);
    free(entry->name);
    free(entry);
  }
}

void nyra_core_debug_declare(LLVMBuilderRef builder, LLVMDIBuilderRef di_builder,
                             LLVMValueRef storage, LLVMMetadataRef scope,
                             LLVMMetadataRef file, const char *name, size_t name_len,
                             LLVMMetadataRef type, unsigned line,
                             unsigned arg_no) {
  LLVMModuleRef module = LLVMGetGlobalParent(LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder)));
  LLVMContextRef context = LLVMGetModuleContext(module);
  if (!type) return;
  LLVMDIFlags variable_flags = name_len > 0 && name[0] == '$'
                                   ? LLVMDIFlagArtificial
                                   : LLVMDIFlagZero;
  LLVMMetadataRef variable = arg_no
      ? LLVMDIBuilderCreateParameterVariable(di_builder, scope, name, name_len, arg_no,
                                             file, line, type, 1, variable_flags)
      : LLVMDIBuilderCreateAutoVariable(di_builder, scope, name, name_len, file, line,
                                       type, 1, variable_flags, 0);
  LLVMMetadataRef expression = LLVMDIBuilderCreateExpression(di_builder, NULL, 0);
  LLVMMetadataRef location = LLVMGetCurrentDebugLocation2(builder);
  if (!variable || !expression || !location) return;
  LLVMDIBuilderInsertDeclareRecordAtEnd(di_builder, storage, variable, expression,
                                       location, LLVMGetInsertBlock(builder));
}
