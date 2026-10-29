// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmProviderBridge;
import "stdlib:stdlib.ny";
import "private/llvm_c.ni";

/** @brief Namespace for provider operations used by native code generators. */
pub struct LlvmNative {}

/** @brief CreateDIBuilder provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CreateDIBuilder(module_ref: *mut void) -> *mut void {
  return LLVMCreateDIBuilder(module_ref);
}

/** @brief DisposeDIBuilder provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DisposeDIBuilder(builder: *mut void) -> void {
  LLVMDisposeDIBuilder(builder);
}

/** @brief DIBuilderCreateFile provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderCreateFile(
  builder: *mut void,
  filename: *const int8,
  filename_len: uintptr,
  directory: *const int8,
  directory_len: uintptr
) -> *mut void {
  return LLVMDIBuilderCreateFile(builder, filename, filename_len, directory, directory_len);
}

/** @brief DIBuilderCreateCompileUnit provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderCreateCompileUnit(
  builder: *mut void,
  language: int32,
  file: *mut void,
  producer: *const int8,
  producer_len: uintptr,
  optimized: int32,
  flags: *const int8,
  flags_len: uintptr,
  runtime_version: uint32,
  split_name: *const int8,
  split_name_len: uintptr,
  emission_kind: int32,
  dwo_id: uint32,
  split_debug_inlining: int32,
  debug_info_for_profiling: int32,
  sysroot: *const int8,
  sysroot_len: uintptr,
  sdk: *const int8,
  sdk_len: uintptr
) -> *mut void {
  return LLVMDIBuilderCreateCompileUnit(builder, language, file, producer, producer_len, optimized, flags, flags_len, runtime_version, split_name, split_name_len, emission_kind, dwo_id, split_debug_inlining, debug_info_for_profiling, sysroot, sysroot_len, sdk, sdk_len);
}

/** @brief DIBuilderCreateSubroutineType provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderCreateSubroutineType(
  builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  flags: uint32
) -> *mut void {
  return LLVMDIBuilderCreateSubroutineType(builder, file, parameter_types, parameter_count, flags);
}

/** @brief DIBuilderCreateFunction provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderCreateFunction(
  builder: *mut void,
  scope_ref: *mut void,
  name: *const int8,
  name_len: uintptr,
  linkage_name: *const int8,
  linkage_len: uintptr,
  file: *mut void,
  line: uint32,
  typ: *mut void,
  local_to_unit: int32,
  is_definition: int32,
  scope_line: uint32,
  flags: uint32,
  optimized: int32
) -> *mut void {
  return LLVMDIBuilderCreateFunction(builder, scope_ref, name, name_len, linkage_name, linkage_len, file, line, typ, local_to_unit, is_definition, scope_line, flags, optimized);
}

/** @brief DIBuilderCreateDebugLocation provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderCreateDebugLocation(
  ctx: *mut void,
  line: uint32,
  column: uint32,
  scope_ref: *mut void,
  inlined_at: *mut void
) -> *mut void {
  return LLVMDIBuilderCreateDebugLocation(ctx, line, column, scope_ref, inlined_at);
}

/** @brief DIBuilderFinalize provider operation; handles remain caller-owned. */
pub static method(LlvmNative) DIBuilderFinalize(builder: *mut void) -> void {
  LLVMDIBuilderFinalize(builder);
}

/** @brief SetSubprogram provider operation; handles remain caller-owned. */
pub static method(LlvmNative) SetSubprogram(function: *mut void, subprogram: *mut void) -> void {
  LLVMSetSubprogram(function, subprogram);
}

/** @brief SetCurrentDebugLocation2 provider operation; handles remain caller-owned. */
pub static method(LlvmNative) SetCurrentDebugLocation2(builder: *mut void, location: *mut void) -> void {
  LLVMSetCurrentDebugLocation2(builder, location);
}

/** @brief MDNodeInContext provider operation; handles remain caller-owned. */
pub static method(LlvmNative) MDNodeInContext(
  context_ref: *mut void,
  values: *mut void,
  count: uint32
) -> *mut void {
  return LLVMMDNodeInContext(context_ref, values, count);
}

/** @brief CoreAddDebugModuleFlags provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreAddDebugModuleFlags(module_ref: *mut void) -> void {
  nyra_core_add_debug_module_flags(module_ref);
}

/** @brief CorePrepareCoffComdats provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CorePrepareCoffComdats(module_ref: *mut void) -> void {
  nyra_core_prepare_coff_comdats(module_ref);
}

/** @brief CoreDebugBasicType provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugBasicType(
  di_builder: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64,
  encoding: uint32
) -> *mut void {
  return nyra_core_debug_basic_type(di_builder, name, name_len, size_bits, encoding);
}

/** @brief CoreDebugPointerType provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugPointerType(
  di_builder: *mut void,
  base_type: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void {
  return nyra_core_debug_pointer_type(di_builder, base_type, name, name_len, size_bits);
}

/** @brief CoreDebugFunctionPointerType provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugFunctionPointerType(
  di_builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void {
  return nyra_core_debug_function_pointer_type(di_builder, file, parameter_types, parameter_count, name, name_len, size_bits);
}

/** @brief CoreDebugArrayType provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugArrayType(
  di_builder: *mut void,
  element_type: *mut void,
  size_bits: uint64,
  align_bits: uint32,
  length: int64
) -> *mut void {
  return nyra_core_debug_array_type(di_builder, element_type, size_bits, align_bits, length);
}

/** @brief CoreDebugCompositeBegin provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugCompositeBegin(
  di_builder: *mut void,
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  is_union: uint32,
  pending: *mut *mut void
) -> *mut void {
  return nyra_core_debug_composite_begin(di_builder, scope_ref, file, name, name_len, line, size_bits, align_bits, is_union, pending);
}

/** @brief CoreDebugCompositeMember provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugCompositeMember(
  di_builder: *mut void,
  composite: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  offset_bits: uint64,
  member_type: *mut void,
  pending: *mut *mut void
) -> uint32 {
  return nyra_core_debug_composite_member(di_builder, composite, file, name, name_len, line, size_bits, align_bits, offset_bits, member_type, pending);
}

/** @brief CoreDebugCompositeEnd provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugCompositeEnd(
  di_builder: *mut void,
  composite: *mut void,
  pending: *mut *mut void
) -> *mut void {
  return nyra_core_debug_composite_end(di_builder, composite, pending);
}

/** @brief CoreDebugCompositeDiscardPending provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugCompositeDiscardPending(pending: *mut *mut void) -> void {
  nyra_core_debug_composite_discard_pending(pending);
}

/** @brief CoreDebugDeclare provider operation; handles remain caller-owned. */
pub static method(LlvmNative) CoreDebugDeclare(
  builder: *mut void,
  di_builder: *mut void,
  storage: *mut void,
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  debug_type: *mut void,
  line: uint32,
  arg_no: uint32
) -> void {
  nyra_core_debug_declare(builder, di_builder, storage, scope_ref, file, name, name_len, debug_type, line, arg_no);
}

/** @brief BuildMemMove provider operation; handles remain caller-owned. */
pub static method(LlvmNative) BuildMemMove(
  builder: *mut void,
  destination: *mut void,
  destination_align: uint32,
  source: *mut void,
  source_align: uint32,
  size: *mut void
) -> *mut void {
  return LLVMBuildMemMove(builder, destination, destination_align, source, source_align, size);
}

/** @brief BuildMemSet provider operation; handles remain caller-owned. */
pub static method(LlvmNative) BuildMemSet(
  builder: *mut void,
  destination: *mut void,
  byte_value: *mut void,
  size: *mut void,
  alignment: uint32
) -> *mut void {
  return LLVMBuildMemSet(builder, destination, byte_value, size, alignment);
}
