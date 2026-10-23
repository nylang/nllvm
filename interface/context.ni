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

/** Create a metadata string value in this context. */
pub method(Context) MetadataString(value: string) -> Value;

/** Create the six-field metadata tuple used by the profile site registry. */
pub method(Context) ProfileSiteMetadata(site_id: Value, symbol_name: Value, path: Value, line: Value, dimensions: Value, tag: Value) -> Value;

/** Create the seven-field RC operation-site row used by `!nyra.profile.rc.sites`. */
pub method(Context) ProfileRcSiteMetadata(site_id: Value, type_id: Value, symbol_name: Value, type_name: Value, operation: Value, path: Value, line: Value) -> Value;

/** Create a two-field RC type registry row used by `!nyra.profile.rc.types`. */
pub method(Context) ProfileRcTypeMetadata(type_id: Value, type_name: Value) -> Value;

/**
 * @brief `i1` type in this context (`LLVMInt1TypeInContext`).
 */
pub method(Context) Int1Type() -> Type;

/**
 * @brief `i8` type in this context (`LLVMInt8TypeInContext`).
 */
pub method(Context) Int8Type() -> Type;

/**
 * @brief `i16` type in this context (`LLVMInt16TypeInContext`).
 */
pub method(Context) Int16Type() -> Type;

/**
 * @brief Integer type with `n` bits (`LLVMIntTypeInContext`).
 */
pub method(Context) IntType(n: uint32) -> Type;

/**
 * @brief `i32` type in this context (`LLVMInt32TypeInContext`).
 */
pub method(Context) Int32Type() -> Type;

/**
 * @brief `i64` type in this context (`LLVMInt64TypeInContext`).
 */
pub method(Context) Int64Type() -> Type;

/**
 * @brief Void type in this context (`LLVMVoidTypeInContext`).
 */
pub method(Context) VoidType() -> Type;

/**
 * @brief `float` type (`LLVMFloatTypeInContext`).
 */
pub method(Context) FloatType() -> Type;

/**
 * @brief `double` type (`LLVMDoubleTypeInContext`).
 */
pub method(Context) DoubleType() -> Type;

/**
 * @brief Unnamed struct type (`LLVMStructTypeInContext`); packs fields to C array.
 * @param fields Element types (borrowed; caller owns the Array).
 * @param packed `LLVMBool` 0/1.
 */
pub method(Context) StructType(fields: *mut Array<Type>, packed: int32) -> Type;

/**
 * @brief Named opaque struct (`LLVMStructCreateNamed`); fill with `Type.StructSetBody`.
 * @param name Struct name (NUL-terminated C string crossing).
 */
pub method(Context) StructCreateNamed(name: string) -> Type;

/**
 * @brief Append a basic block to `fn` (`LLVMAppendBasicBlockInContext`).
 * @param fn Function value.
 * @param name Block name.
 */
pub method(Context) AppendBasicBlock(fn: Value, name: string) -> BasicBlock;

/**
 * @brief String constant in this context (`LLVMConstStringInContext`).
 * @param s Payload bytes (length = `s.length`).
 * @param add_null `LLVMBool` 1 → append NUL (DontNullTerminate = 0).
 */
pub method(Context) ConstString(s: string, add_null: int32) -> Value;

/** Create a literal LLVM struct constant (`LLVMConstStructInContext`). */
pub method(Context) ConstStruct(elems: *mut Array<Value>, packed: int32) -> Value;

/** Borrow the process-lifetime context; Dispose on this handle is a no-op. */
pub static method(Context) Global() -> Context;
