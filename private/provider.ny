// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmProviderBridge;
import "stdlib:stdlib.ny";
import "private/llvm_c.ni";
import "public/handles.ny";
import "interface/provider.ni";

/** @brief One native DWARF builder with its own pending composite records. */
pub struct DwarfBuilder {
  handle: *mut void;
  pending: *mut void;
}

/**
 * @brief Create one native DWARF builder for a borrowed LLVM module.
 * @returns Live builder, or an inert value when native creation fails.
 * @note Finalize and Dispose before releasing the borrowed module/context. Do not copy a live value.
 */
pub static method(DwarfBuilder) New(module_ref: *mut void) -> DwarfBuilder {
  return DwarfBuilder{handle: LLVMCreateDIBuilder(module_ref), pending: 0 as *mut void};
}

/**
 * @brief Discard pending bookkeeping and dispose the native DIBuilder exactly once.
 */
pub method(DwarfBuilder) Dispose() -> void {
  self.DiscardPending();
  if self.IsValid() {
    LLVMDisposeDIBuilder(self.handle);
    self.handle = 0 as *mut void;
  }
}

/**
 * @brief Create file metadata from borrowed filename and directory byte spans.
 * @returns Metadata owned by the LLVM context; spans are read only during this call.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CreateFile(
  filename: *const int8,
  filename_len: uintptr,
  directory: *const int8,
  directory_len: uintptr
) -> *mut void {
  return LLVMDIBuilderCreateFile(self.handle, filename, filename_len, directory, directory_len);
}

/**
 * @brief Create compile-unit metadata using the supplied DWARF attributes.
 * @returns Compile-unit metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CreateCompileUnit(
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
  return LLVMDIBuilderCreateCompileUnit(
    self.handle,
    language,
    file,
    producer,
    producer_len,
    optimized,
    flags,
    flags_len,
    runtime_version,
    split_name,
    split_name_len,
    emission_kind,
    dwo_id,
    split_debug_inlining,
    debug_info_for_profiling,
    sysroot,
    sysroot_len,
    sdk,
    sdk_len
  );
}

/**
 * @brief Create a subroutine signature from a borrowed array of parameter metadata.
 * @returns Subroutine-type metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CreateSubroutineType(
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  flags: uint32
) -> *mut void {
  return LLVMDIBuilderCreateSubroutineType(self.handle, file, parameter_types, parameter_count, flags);
}

/**
 * @brief Create subprogram metadata with explicit scope, linkage name and source location.
 * @returns Subprogram metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CreateFunction(
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
  return LLVMDIBuilderCreateFunction(
    self.handle,
    scope_ref,
    name,
    name_len,
    linkage_name,
    linkage_len,
    file,
    line,
    typ,
    local_to_unit,
    is_definition,
    scope_line,
    flags,
    optimized
  );
}

/**
 * @brief Create an instruction source location in this LLVM context.
 * @returns Location metadata borrowing the context lifetime.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Context) DebugLocation(
  line: uint32,
  column: uint32,
  scope_ref: *mut void,
  inlined_at: *mut void
) -> *mut void {
  return LLVMDIBuilderCreateDebugLocation(self.handle, line, column, scope_ref, inlined_at);
}

/**
 * @brief Finalize pending metadata before native builder disposal.
 * @note Default/disposed values are inert. Pending composites must be completed or discarded first.
 */
pub method(DwarfBuilder) Finalize() -> void {
  if self.IsValid() {
    LLVMDIBuilderFinalize(self.handle);
  }
}

/**
 * @brief Attach subprogram metadata to this function value.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Value) SetSubprogram(subprogram: *mut void) -> void {
  LLVMSetSubprogram(self.handle, subprogram);
}

/**
 * @brief Set this instruction builder's current source location.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Builder) SetDebugLocation(location: *mut void) -> void {
  LLVMSetCurrentDebugLocation2(self.handle, location);
}

/**
 * @brief Construct a metadata node from a borrowed LLVM value-reference array.
 * @returns Metadata value owned by this LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Context) MetadataNode(
  values: *mut void, count: uint32) -> *mut void {
  return LLVMMDNodeInContext(self.handle, values, count);
}

/**
 * @brief Install the compiler's required DWARF/debug-version module flags.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Module) AddDebugFlags() -> void {
  nyra_core_add_debug_module_flags(self.handle);
}

/**
 * @brief Prepare this module's weak definitions for COFF COMDAT emission.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Module) PrepareCoffComdats() -> void {
  nyra_core_prepare_coff_comdats(self.handle);
}

/**
 * @brief Create a primitive DWARF type using bit size and encoding.
 * @returns Type metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) BasicType(
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64,
  encoding: uint32
) -> *mut void {
  return nyra_core_debug_basic_type(self.handle, name, name_len, size_bits, encoding);
}

/**
 * @brief Create a named DWARF pointer type for the selected target bit size.
 * @returns Type metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) PointerType(
  base_type: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void {
  return nyra_core_debug_pointer_type(self.handle, base_type, name, name_len, size_bits);
}

/**
 * @brief Create a DWARF function pointer from parameter metadata and target size.
 * @returns Pointer type metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) FunctionPointerType(
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void {
  return nyra_core_debug_function_pointer_type(
    self.handle,
    file,
    parameter_types,
    parameter_count,
    name,
    name_len,
    size_bits
  );
}

/**
 * @brief Create a fixed-length DWARF array with explicit element, bit size and alignment.
 * @returns Array type metadata owned by the LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) ArrayType(
  element_type: *mut void,
  size_bits: uint64,
  align_bits: uint32,
  length: int64
) -> *mut void {
  return nyra_core_debug_array_type(self.handle, element_type, size_bits, align_bits, length);
}

/**
 * @brief Begin a recursive structure or union and retain its pending bookkeeping.
 * @returns Replaceable composite metadata, or null on bookkeeping allocation failure.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CompositeBegin(
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  is_union: uint32
) -> *mut void {
  return nyra_core_debug_composite_begin(
    self.handle,
    scope_ref,
    file,
    name,
    name_len,
    line,
    size_bits,
    align_bits,
    is_union,
    &mut self.pending
  );
}

/**
 * @brief Append a member only to a composite pending in this builder.
 * @returns One on success; zero for an unknown composite, missing type or native allocation failure.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CompositeMember(
  composite: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  offset_bits: uint64,
  member_type: *mut void
) -> uint32 {
  return nyra_core_debug_composite_member(
    self.handle,
    composite,
    file,
    name,
    name_len,
    line,
    size_bits,
    align_bits,
    offset_bits,
    member_type,
    &mut self.pending
  );
}

/**
 * @brief Complete a pending composite and retire its bookkeeping from this builder.
 * @returns Completed metadata, or null for an unknown composite/native construction failure.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CompositeEnd(
  composite: *mut void) -> *mut void {
  return nyra_core_debug_composite_end(self.handle, composite, &mut self.pending);
}

/**
 * @brief Discard this builder's unfinished composite records without accessing its LLVM module.
 */
pub method(DwarfBuilder) DiscardPending() -> void {
  nyra_core_debug_composite_discard_pending(&mut self.pending);
}

/**
 * @brief Insert a local/argument declaration for storage at the supplied debug scope and source line.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) Declare(
  builder: *mut void,
  storage: *mut void,
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  debug_type: *mut void,
  line: uint32,
  arg_no: uint32
) -> void {
  nyra_core_debug_declare(builder, self.handle, storage, scope_ref, file, name, name_len, debug_type, line, arg_no);
}

/**
 * @brief Emit an overlap-safe memory move with explicit source/destination alignments.
 * @returns Instruction value owned by the containing LLVM module.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Builder) MemMove(
  destination: *mut void,
  destination_align: uint32,
  source: *mut void,
  source_align: uint32,
  size: *mut void
) -> *mut void {
  return LLVMBuildMemMove(self.handle, destination, destination_align, source, source_align, size);
}

/**
 * @brief Emit a byte fill with an explicit destination alignment.
 * @returns Instruction value owned by the containing LLVM module.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Builder) MemSet(
  destination: *mut void,
  byte_value: *mut void,
  size: *mut void,
  alignment: uint32
) -> *mut void {
  return LLVMBuildMemSet(self.handle, destination, byte_value, size, alignment);
}

/** @brief Whether native DWARF builder state is live.
 * @returns False for default, failed creation and disposed values. */
pub method(DwarfBuilder) IsValid() -> bool {
  return self.handle != nil;
}

/** @brief Transfer the native builder and pending records to a new value.
 * @returns Sole live value; the moved-from value is inert. */
pub method(DwarfBuilder) operator move() -> DwarfBuilder {
  let handle: *mut void = self.handle;
  let pending: *mut void = self.pending;
  self.handle = 0 as *mut void;
  self.pending = 0 as *mut void;
  return DwarfBuilder{handle: handle, pending: pending};
}

/** @brief Release unfinished composite bookkeeping without accessing the native module. */
pub method(DwarfBuilder) operator drop() -> void {
  self.DiscardPending();
}

/**
 * @brief Copying a pending-record owner would duplicate native cleanup ownership.
 * @returns Deleted operation; transfer the live builder with move instead.
 */
pub method(DwarfBuilder) operator copy() -> DwarfBuilder = delete;

/**
 * @brief Create DWARF file metadata from a logical source path without filesystem access.
 * @param path Borrowed spelling; slash and backslash delimiters split the directory and filename.
 * @returns Context-owned metadata; a missing filename uses unknown.ny and an absent directory uses dot.
 * @note Requires a live builder. The input path is read only during the call.
 */
pub method(DwarfBuilder) CreateSourceFile(path: ref string) -> *mut void {
  var slash: int32 = 0 - 1;
  var i: int32 = 0;
  while i < path.length {
    if path[i] == '/' || (path[i] as int32) == 92 {
      slash = i;
    }

    i = i + 1;
  }

  var filename: string = path;
  var directory: string = ".";
  if slash >= 0 {
    filename = path.Slice(slash + 1, path.length);
    if slash == 0 {
      directory = path.Slice(0, 1);
    } else {
      directory = path.Slice(0, slash);
    }
  }

  if filename.length == 0 {
    filename = "unknown.ny";
  }

  return self.CreateFile(
    filename.data as *const int8,
    filename.length as uintptr,
    directory.data as *const int8,
    directory.length as uintptr
  );
}
