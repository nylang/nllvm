/**
 * @brief Product face for LLVM `LLVMTypeRef` — ints/ptr/fn/struct/array (v1).
 * @note Handle is opaque; types die with their Context. Never `nyra_free`.
 * @note Non-empty `Array` args are passed as `*mut Array` (borrow) because method
 *       args do not currently move owned aggregates — by-value would double-free.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

import "stdlib:stdlib.ny";

/**
 * @brief Opaque wrapper around `LLVMTypeRef` (`*mut void`).
 */
pub struct Type;

/**
 * @brief Pointer type in address space 0 (`LLVMPointerType`).
 * @param elem Pointee type.
 */
pub static method(Type) Pointer(elem: Type) -> Type;

/**
 * @brief Function type (`LLVMFunctionType`); packs `params` to `LLVMTypeRef*` + count.
 * @param ret Return type.
 * @param params Parameter types in order (borrowed via `*mut`; caller owns the Array).
 * @param is_var_arg `LLVMBool` 0/1.
 */
pub static method(Type) Function(ret: Type, params: *mut Array<Type>, is_var_arg: int32) -> Type;

/**
 * @brief Set body of a named opaque struct (`LLVMStructSetBody`).
 * @param fields Element types (borrowed via `*mut`; caller owns the Array).
 * @param packed `LLVMBool` 0/1.
 */
pub method(Type) StructSetBody(fields: *mut Array<Type>, packed: int32) -> void;

/**
 * @brief Fixed array type (`LLVMArrayType`).
 * @param elem Element type.
 * @param n Element count (`unsigned`).
 */
pub static method(Type) Array(elem: Type, n: uint32) -> Type;
/** @brief Fixed array type using LLVM's full 64-bit element count. */
pub static method(Type) Array64(elem: Type, n: uint64) -> Type;

/** @brief Fixed-length LLVM vector type (`LLVMVectorType`). */
pub static method(Type) Vector(elem: Type, n: uint32) -> Type;

/**
 * @brief `LLVMGetTypeKind` (Integer=8, Function=9, Struct=10, Array=11, Pointer=12, Float=2, Double=3).
 */
pub method(Type) Kind() -> int32;

/**
 * @brief `LLVMGetIntTypeWidth` (integer types only).
 */
pub method(Type) IntWidth() -> uint32;

/**
 * @brief `LLVMCountStructElementTypes`.
 */
pub method(Type) StructElementCount() -> uint32;

/**
 * @brief `LLVMStructGetTypeAtIndex`.
 */
pub method(Type) StructElement(i: uint32) -> Type;

/**
 * @brief `LLVMCountParamTypes` (function types).
 */
pub method(Type) ParamCount() -> uint32;

/**
 * @brief `LLVMGetParamTypes` slot `i` (copies all then indexes).
 */
pub method(Type) ParamType(i: uint32) -> Type;
