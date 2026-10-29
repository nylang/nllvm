// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief Product face for LLVM `LLVMContextRef` — Create / Dispose / types / BB.
 * @note Handle is opaque; never `nyra_free` it. Pair every Create with Dispose.
 * @see docs/design/compiler/nyra-llvm.md §1.3 · m_v0.6_p2 Record
 */
import "stdlib:stdlib.ny";
import "interface/type.ni";
import "interface/value.ni";
import "interface/basic_block.ni";

/**
 * @brief Opaque wrapper around `LLVMContextRef` (`*mut void`).
 */
pub struct Context;

/**
 * @brief Allocate a new LLVM context (`LLVMContextCreate`).
 * @returns Context owning the foreign handle; caller must `Dispose`.
 */
pub static method(Context) Create() -> Context;

/**
 * @brief Destroy this context (`LLVMContextDispose`). Do not `nyra_free`.
 */
pub method(Context) Dispose() -> void;

/**
 * @brief Create a metadata string value in this context.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) MetadataString(value: string) -> Value;

/**
 * @brief Create the six-field metadata tuple used by the profile site registry.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileSiteMetadata(
  site_id: Value,
  symbol_name: Value,
  path: Value,
  line: Value,
  dimensions: Value,
  tag: Value
) -> Value;

/**
 * @brief Create the seven-field RC operation-site row used by `!nyra.profile.rc.sites`.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileRcSiteMetadata(
  site_id: Value,
  type_id: Value,
  symbol_name: Value,
  type_name: Value,
  operation: Value,
  path: Value,
  line: Value
) -> Value;

/**
 * @brief Create a two-field RC type registry row used by `!nyra.profile.rc.types`.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileRcTypeMetadata(type_id: Value, type_name: Value) -> Value;

/**
 * @brief `i1` type in this context (`LLVMInt1TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int1Type() -> Type;

/**
 * @brief `i8` type in this context (`LLVMInt8TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int8Type() -> Type;

/**
 * @brief `i16` type in this context (`LLVMInt16TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int16Type() -> Type;

/**
 * @brief Integer type with `n` bits (`LLVMIntTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) IntType(n: uint32) -> Type;

/**
 * @brief `i32` type in this context (`LLVMInt32TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int32Type() -> Type;

/**
 * @brief `i64` type in this context (`LLVMInt64TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int64Type() -> Type;

/**
 * @brief Void type in this context (`LLVMVoidTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) VoidType() -> Type;

/**
 * @brief `float` type (`LLVMFloatTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) FloatType() -> Type;

/**
 * @brief `double` type (`LLVMDoubleTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) DoubleType() -> Type;

/**
 * @brief Unnamed struct type (`LLVMStructTypeInContext`); packs fields to C array.
 * @param fields Element types (borrowed; caller owns the Array).
 * @param packed `LLVMBool` 0/1.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) StructType(fields: *mut Array<Type>, packed: int32) -> Type;

/**
 * @brief Named opaque struct (`LLVMStructCreateNamed`); fill with `Type.StructSetBody`.
 * @param name Struct name (NUL-terminated C string crossing).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) StructCreateNamed(name: string) -> Type;

/**
 * @brief Append a basic block to `fn` (`LLVMAppendBasicBlockInContext`).
 * @param fn Function value.
 * @param name Block name.
 * @returns Borrowed LLVM basic-block handle; its enclosing module owns the foreign storage.
 */
pub method(Context) AppendBasicBlock(fn: Value, name: string) -> BasicBlock;

/**
 * @brief String constant in this context (`LLVMConstStringInContext`).
 * @param s Payload bytes (length = `s.length`).
 * @param add_null `LLVMBool` 1 → append NUL (DontNullTerminate = 0).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ConstString(s: string, add_null: int32) -> Value;

/**
 * @brief Create a literal LLVM struct constant (`LLVMConstStructInContext`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ConstStruct(elems: *mut Array<Value>, packed: int32) -> Value;

/**
 * @brief Borrow the process-lifetime context; Dispose on this handle is a no-op.
 * @returns Borrowed process-lifetime context; Dispose is a no-op for this handle.
 */
pub static method(Context) Global() -> Context;
