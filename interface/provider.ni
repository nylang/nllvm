// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief Explicit low-level provider calls; emitter owns native handle lifetimes. */
import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/module.ni";
import "interface/value.ni";
import "interface/builder.ni";
/**
 * @brief Native DWARF builder and its pending recursive-composite bookkeeping.
 * @note Explicitly Finalize and Dispose before module/context disposal. Do not copy a live value.
 */
pub struct DwarfBuilder;

/**
 * @brief Create one native DWARF builder for a borrowed LLVM module.
 * @returns Live builder, or an inert value when native creation fails.
 * @note Finalize and Dispose before releasing the borrowed module/context. Do not copy a live value.
 */
pub static method(DwarfBuilder) New(module_ref: *mut void) -> DwarfBuilder ;

/**
 * @brief Discard pending bookkeeping and dispose the native DIBuilder exactly once.
 */
pub method(DwarfBuilder) Dispose() -> void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

/**
 * @brief Finalize pending metadata before native builder disposal.
 * @note Default/disposed values are inert. Pending composites must be completed or discarded first.
 */
pub method(DwarfBuilder) Finalize() -> void;

/**
 * @brief Attach subprogram metadata to this function value.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Value) SetSubprogram(subprogram: *mut void) -> void;

/**
 * @brief Set this instruction builder's current source location.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Builder) SetDebugLocation(location: *mut void) -> void;

/**
 * @brief Construct a metadata node from a borrowed LLVM value-reference array.
 * @returns Metadata value owned by this LLVM context.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Context) MetadataNode(
  values: *mut void, count: uint32) -> *mut void;

/**
 * @brief Install the compiler's required DWARF/debug-version module flags.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Module) AddDebugFlags() -> void;

/**
 * @brief Prepare this module's weak definitions for COFF COMDAT emission.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(Module) PrepareCoffComdats() -> void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> *mut void;

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
) -> uint32;

/**
 * @brief Complete a pending composite and retire its bookkeeping from this builder.
 * @returns Completed metadata, or null for an unknown composite/native construction failure.
 * @note Requires live handles from the same LLVM context; input pointers are borrowed for the call.
 */
pub method(DwarfBuilder) CompositeEnd(
  composite: *mut void) -> *mut void;

/**
 * @brief Discard this builder's unfinished composite records without accessing its LLVM module.
 */
pub method(DwarfBuilder) DiscardPending() -> void;

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
) -> void;

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
) -> *mut void;

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
) -> *mut void;

/** @brief Whether native DWARF builder state is live.
 * @returns False for default, failed creation and disposed values. */
pub method(DwarfBuilder) IsValid() -> bool;
/** @brief Transfer the native builder and pending records to a new value.
 * @returns Sole live value; the moved-from value is inert. */
pub method(DwarfBuilder) operator move() -> DwarfBuilder;
/** @brief Discard pending records only; explicit Dispose owns native-builder cleanup. */
pub method(DwarfBuilder) operator drop() -> void;

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
pub method(DwarfBuilder) CreateSourceFile(path: ref string) -> *mut void;
