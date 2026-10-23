/**
 * @brief Product face for LLVM `LLVMValueRef` — functions, params, constants, globals (v1).
 * @note Values die with the Module; do not Dispose them separately.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

import "stdlib:stdlib.ny";
import "interface/type.ni";
import "interface/basic_block.ni";

/**
 * @brief Opaque wrapper around `LLVMValueRef` (`*mut void`).
 */
pub struct Value;

/**
 * @brief Function parameter at index `i` (`LLVMGetParam`).
 * @param i Zero-based parameter index.
 */
pub method(Value) Param(i: int32) -> Value;

/**
 * @brief Undef constant (`LLVMGetUndef`).
 */
pub static method(Value) ConstUndef(ty: Type) -> Value;

/**
 * @brief Integer constant (`LLVMConstInt`).
 * @param n Bit pattern as `uint64` (`unsigned long long`).
 * @param sign_extend `LLVMBool` 0/1.
 */
pub static method(Value) ConstInt(ty: Type, n: uint64, sign_extend: int32) -> Value;

/** Constant pointer-to-integer conversion (`LLVMConstPtrToInt`). */
pub static method(Value) ConstPtrToInt(v: Value, to: Type) -> Value;

/**
 * @brief Null pointer constant (`LLVMConstPointerNull`).
 */
pub static method(Value) ConstPointerNull(ty: Type) -> Value;

/**
 * @brief Null constant of any type (`LLVMConstNull`).
 */
pub static method(Value) ConstNull(ty: Type) -> Value;

/**
 * @brief Floating constant (`LLVMConstReal`).
 */
pub static method(Value) ConstReal(ty: Type, n: float64) -> Value;

/** Parse an LLVM floating literal directly, preserving the source decimal's rounding. */
pub static method(Value) ConstRealFromString(ty: Type, text: string) -> Value;

/** Read a floating constant as binary64 (`LLVMConstRealGetDouble`). */
pub method(Value) ConstRealGetDouble() -> float64;

/**
 * @brief Runtime type of this value (`LLVMTypeOf`).
 */
pub method(Value) TypeOf() -> Type;

/**
 * @brief Add a `switch` case (`LLVMAddCase`).
 */
pub method(Value) AddCase(on_val: Value, dest: BasicBlock) -> void;

/**
 * @brief PHI incoming (`LLVMAddIncoming`); `vals` and `blocks` same length.
 */
pub method(Value) AddIncoming(vals: *mut Array<Value>, blocks: *mut Array<BasicBlock>) -> void;

/**
 * @brief Named-struct constant (`LLVMConstNamedStruct`); packs elems to C array.
 * @param elems Element values (borrowed via `*mut`; caller owns the Array).
 */
pub static method(Value) ConstNamedStruct(ty: Type, elems: *mut Array<Value>) -> Value;


/**
 * @brief Constant in-bounds GEP (`LLVMConstInBoundsGEP2`) for static string packs.
 * @param ty Source aggregate/array type of `base`.
 * @param base Constant pointer (typically a private string global).
 * @param indices Constant index values.
 */
pub static method(Value) ConstInBoundsGEP(ty: Type, base: Value, indices: *mut Array<Value>) -> Value;

/**
 * @brief Set global initializer (`LLVMSetInitializer`).
 */
pub method(Value) SetInitializer(v: Value) -> void;

/**
 * @brief Set linkage (`LLVMSetLinkage`); Internal=8, Private=9 (LLVM C enum w/ obsolete slots).
 */
pub method(Value) SetLinkage(kind: int32) -> void;
pub method(Value) SetOrdering(ordering: int32) -> void;
pub method(Value) SetWeak(is_weak: int32) -> void;

/**
 * @brief Mark global constant (`LLVMSetGlobalConstant`); `b` is `LLVMBool` 0/1.
 */
pub method(Value) SetGlobalConstant(b: int32) -> void;
/** @brief Mark a global thread-local (`LLVMSetThreadLocal`); `b` is 0/1. */
pub method(Value) SetThreadLocal(b: int32) -> void;

/**
 * @brief True when a function already has an entry basic block (`LLVMGetEntryBasicBlock`).
 */
pub method(Value) HasEntryBlock() -> bool;

/** Add an LLVM function enum attribute; returns false for an unknown name. */
pub method(Value) AddFunctionEnumAttribute(name: string, value: uint64) -> bool;
pub method(Value) AddEnumAttributeAtIndex(index: uint32, name: string, value: uint64) -> bool;
pub method(Value) AddCallSiteEnumAttribute(index: uint32, name: string, value: uint64) -> bool;
pub method(Value) AddTypeAttributeAtIndex(index: uint32, name: string, type_handle: *mut void) -> bool;
pub method(Value) AddCallSiteTypeAttribute(index: uint32, name: string, type_handle: *mut void) -> bool;
pub method(Value) SetAlignment(bytes: uint32) -> void;
