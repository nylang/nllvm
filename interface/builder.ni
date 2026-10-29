// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief Product face for LLVM `LLVMBuilderRef` — IRBuilder v1 through call/GEP/ret.
 * @note Handle is opaque; never `nyra_free`. Pair every Create with Dispose.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */
import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/type.ni";
import "interface/value.ni";
import "interface/basic_block.ni";

/**
 * @brief Opaque wrapper around `LLVMBuilderRef` (`*mut void`).
 */
pub struct Builder;

/**
 * @brief Create a builder in `ctx` (`LLVMCreateBuilderInContext`).
 * @returns The Builder value described above, retaining the documented ownership and
 *   default-state semantics.
 */
pub static method(Builder) Create(ctx: Context) -> Builder;

/**
 * @brief Destroy this builder (`LLVMDisposeBuilder`). Do not `nyra_free`.
 */
pub method(Builder) Dispose() -> void;

/**
 * @brief Position at end of `bb` (`LLVMPositionBuilderAtEnd`).
 */
pub method(Builder) PositionAtEnd(bb: BasicBlock) -> void;

/**
 * @brief Position before an instruction (`LLVMPositionBuilderBefore`).
 */
pub method(Builder) PositionBefore(instr: Value) -> void;

/**
 * @brief Alloca in `fn`'s entry block before the first instruction (Go createEntryAlloca).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildEntryAlloca(fn: Value, ty: Type, name: string) -> Value;

/**
 * @brief Entry alloca + optional immediate store (Go `createEntryAllocaInit`).
 * @param init_val Null handle skips the store; otherwise `store init_val` before restoring IP.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildEntryAllocaInit(fn: Value, ty: Type, name: string, init_val: Value) -> Value;

/**
 * @brief Stack alloca (`LLVMBuildAlloca`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildAlloca(ty: Type, name: string) -> Value;

/**
 * @brief Allocate count elements of the given type in the current stack frame.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildArrayAlloca(ty: Type, count: Value, name: string) -> Value;

/**
 * @brief Typed load (`LLVMBuildLoad2`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildLoad(ty: Type, ptr: Value, name: string) -> Value;

/**
 * @brief Store (`LLVMBuildStore`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildStore(val: Value, ptr: Value) -> Value;

/**
 * @brief Integer add (`LLVMBuildAdd`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildAdd(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Return a value (`LLVMBuildRet`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildRet(v: Value) -> Value;

/**
 * @brief Void return (`LLVMBuildRetVoid`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildRetVoid() -> Value;

/**
 * @brief Unreachable terminator (`LLVMBuildUnreachable`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildUnreachable() -> Value;

/**
 * @brief Unconditional branch (`LLVMBuildBr`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildBr(dest: BasicBlock) -> Value;

/**
 * @brief Conditional branch (`LLVMBuildCondBr`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildCondBr(cond: Value, then_bb: BasicBlock, else_bb: BasicBlock) -> Value;

/**
 * @brief Call (`LLVMBuildCall2`); packs `args` to `LLVMValueRef*` + count.
 * @param fn_ty Function type.
 * @param fn Callee value.
 * @param args Call arguments (borrowed via `*mut`; caller owns the Array).
 * @param name Result name (empty OK for void).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildCall(fn_ty: Type, fn: Value, args: *mut Array<Value>, name: string) -> Value;

/**
 * @brief Inbounds GEP (`LLVMBuildInBoundsGEP2`); packs `indices` to C array.
 * @param ty Aggregate type being indexed.
 * @param ptr Base pointer.
 * @param indices Index values (borrowed via `*mut`; caller owns the Array).
 * @param name Result name.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildInBoundsGEP(ty: Type, ptr: Value, indices: *mut Array<Value>, name: string) -> Value;

/**
 * @brief Insert value into aggregate (`LLVMBuildInsertValue`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildInsertValue(agg: Value, elt: Value, idx: uint32, name: string) -> Value;

/**
 * @brief Borrow the current insertion block without changing builder position.
 * @returns Borrowed LLVM block handle; no ownership transfer.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) GetInsertBlock() -> BasicBlock;

/**
 * @brief Build integer subtraction of the two operands.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSub(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build integer multiplication of the two operands.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildMul(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build signed integer division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSDiv(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build unsigned integer division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildUDiv(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build signed integer remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSRem(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build unsigned integer remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildURem(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build bitwise conjunction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAnd(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build bitwise disjunction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildOr(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build bitwise exclusive-or.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildXor(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build a left shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildShl(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build a sign-propagating right shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAShr(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build a zero-filling right shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildLShr(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build integer negation.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildNeg(v: Value, name: string) -> Value;

/**
 * @brief Build bitwise complement.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildNot(v: Value, name: string) -> Value;

/**
 * @brief Build floating-point addition.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFAdd(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build floating-point subtraction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFSub(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build floating-point multiplication.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFMul(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build floating-point division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFDiv(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build floating-point remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFRem(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Build floating-point negation.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFNeg(v: Value, name: string) -> Value;

/**
 * @brief Compare integer operands with the supplied LLVM integer predicate.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildICmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Compare floating operands with the supplied LLVM real predicate.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFCmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Truncate an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildTrunc(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Sign-extend an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSExt(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Zero-extend an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildZExt(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Narrow a floating value to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPTrunc(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Widen a floating value to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPExt(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Convert a signed integer to floating point.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSIToFP(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Convert a floating value to a signed integer.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPToSI(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Reinterpret a value using an LLVM-compatible destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildBitCast(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Convert a pointer value to an integer type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildPtrToInt(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Convert an integer value to a pointer type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildIntToPtr(v: Value, dest: Type, name: string) -> Value;

/**
 * @brief Extract the aggregate element at the supplied zero-based index.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildExtractValue(agg: Value, idx: uint32, name: string) -> Value;

/**
 * @brief Select between two values using an LLVM condition.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSelect(cond: Value, then_v: Value, else_v: Value, name: string) -> Value;

/**
 * @brief Build a switch terminator with a default destination and reserved case capacity.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSwitch(v: Value, else_bb: BasicBlock, num_cases: uint32) -> Value;

/**
 * @brief Create a PHI node; populate its incoming values with Value.AddIncoming.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildPhi(ty: Type, name: string) -> Value;

/**
 * @brief Build an atomic fence with the supplied ordering and thread scope.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFence(ordering: int32, single_thread: int32, name: string) -> Value;

/**
 * @brief Build an atomic read-modify-write operation on the supplied pointer.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAtomicRMW(
  op: int32,
  ptr: Value,
  val: Value,
  ordering: int32,
  single_thread: int32
) -> Value;

/**
 * @brief Build compare-exchange with separate success and failure orderings.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAtomicCmpXchg(
  ptr: Value,
  cmp: Value,
  new_v: Value,
  success_ordering: int32,
  failure_ordering: int32,
  single_thread: int32
) -> Value;

/** @brief `LLVMAtomicRMWBinOp` (Core.h). */
pub static kAtomicRmwXchg: int32 = 0;

/**
 * @brief LLVM atomic read-modify-write opcode for addition.
 */
pub static kAtomicRmwAdd: int32 = 1;

/**
 * @brief LLVM atomic read-modify-write opcode for subtraction.
 */
pub static kAtomicRmwSub: int32 = 2;

/**
 * @brief LLVM atomic read-modify-write opcode for bitwise conjunction.
 */
pub static kAtomicRmwAnd: int32 = 3;

/**
 * @brief LLVM atomic read-modify-write opcode for bitwise disjunction.
 */
pub static kAtomicRmwOr: int32 = 5;

/**
 * @brief LLVM atomic read-modify-write opcode for bitwise exclusive-or.
 */
pub static kAtomicRmwXor: int32 = 6;

/** @brief `LLVMAtomicOrderingSequentiallyConsistent`. */
pub static kAtomicOrderingSeqCst: int32 = 7;

/** @brief `LLVMAtomicOrderingAcquire`. */
pub static kAtomicOrderingAcquire: int32 = 4;

/** @brief `LLVMAtomicOrderingRelease`. */
pub static kAtomicOrderingRelease: int32 = 5;

/** @brief `LLVMAtomicOrderingAcquireRelease`. */
pub static kAtomicOrderingAcqRel: int32 = 6;

/** @brief `LLVMAtomicOrderingMonotonic` (Relaxed). */
pub static kAtomicOrderingMonotonic: int32 = 2;

/**
 * @brief LLVM integer predicate: equal.
 */
pub static kICmpEQ: int32 = 32;

/**
 * @brief LLVM integer predicate: not equal.
 */
pub static kICmpNE: int32 = 33;

/**
 * @brief LLVM integer predicate: unsigned greater than.
 */
pub static kICmpUGT: int32 = 34;

/**
 * @brief LLVM integer predicate: unsigned greater than or equal.
 */
pub static kICmpUGE: int32 = 35;

/**
 * @brief LLVM integer predicate: unsigned less than.
 */
pub static kICmpULT: int32 = 36;

/**
 * @brief LLVM integer predicate: unsigned less than or equal.
 */
pub static kICmpULE: int32 = 37;

/**
 * @brief LLVM integer predicate: signed greater than.
 */
pub static kICmpSGT: int32 = 38;

/**
 * @brief LLVM integer predicate: signed greater than or equal.
 */
pub static kICmpSGE: int32 = 39;

/**
 * @brief LLVM integer predicate: signed less than.
 */
pub static kICmpSLT: int32 = 40;

/**
 * @brief LLVM integer predicate: signed less than or equal.
 */
pub static kICmpSLE: int32 = 41;

/**
 * @brief LLVM floating-point predicate: ordered equal.
 */
pub static kFCmpOEQ: int32 = 1;

/**
 * @brief LLVM floating-point predicate: ordered greater than.
 */
pub static kFCmpOGT: int32 = 2;

/**
 * @brief LLVM floating-point predicate: ordered greater than or equal.
 */
pub static kFCmpOGE: int32 = 3;

/**
 * @brief LLVM floating-point predicate: ordered less than.
 */
pub static kFCmpOLT: int32 = 4;

/**
 * @brief LLVM floating-point predicate: ordered less than or equal.
 */
pub static kFCmpOLE: int32 = 5;

/**
 * @brief LLVM floating-point predicate: ordered not equal.
 */
pub static kFCmpONE: int32 = 6;

/** @brief LLVM real unordered-or-not-equal predicate (`LLVMRealUNE`). */
pub static kFCmpUNE: int32 = 14;
