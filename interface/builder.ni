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
 */
pub method(Builder) BuildEntryAlloca(fn: Value, ty: Type, name: string) -> Value;

/**
 * @brief Entry alloca + optional immediate store (Go `createEntryAllocaInit`).
 * @param init_val Null handle skips the store; otherwise `store init_val` before restoring IP.
 */
pub method(Builder) BuildEntryAllocaInit(fn: Value, ty: Type, name: string, init_val: Value) -> Value;

/**
 * @brief Stack alloca (`LLVMBuildAlloca`).
 */
pub method(Builder) BuildAlloca(ty: Type, name: string) -> Value;
pub method(Builder) BuildArrayAlloca(ty: Type, count: Value, name: string) -> Value;

/**
 * @brief Typed load (`LLVMBuildLoad2`).
 */
pub method(Builder) BuildLoad(ty: Type, ptr: Value, name: string) -> Value;

/**
 * @brief Store (`LLVMBuildStore`).
 */
pub method(Builder) BuildStore(val: Value, ptr: Value) -> Value;

/**
 * @brief Integer add (`LLVMBuildAdd`).
 */
pub method(Builder) BuildAdd(lhs: Value, rhs: Value, name: string) -> Value;

/**
 * @brief Return a value (`LLVMBuildRet`).
 */
pub method(Builder) BuildRet(v: Value) -> Value;

/**
 * @brief Void return (`LLVMBuildRetVoid`).
 */
pub method(Builder) BuildRetVoid() -> Value;

/**
 * @brief Unreachable terminator (`LLVMBuildUnreachable`).
 */
pub method(Builder) BuildUnreachable() -> Value;

/**
 * @brief Unconditional branch (`LLVMBuildBr`).
 */
pub method(Builder) BuildBr(dest: BasicBlock) -> Value;

/**
 * @brief Conditional branch (`LLVMBuildCondBr`).
 */
pub method(Builder) BuildCondBr(cond: Value, then_bb: BasicBlock, else_bb: BasicBlock) -> Value;

/**
 * @brief Call (`LLVMBuildCall2`); packs `args` to `LLVMValueRef*` + count.
 * @param fn_ty Function type.
 * @param fn Callee value.
 * @param args Call arguments (borrowed via `*mut`; caller owns the Array).
 * @param name Result name (empty OK for void).
 */
pub method(Builder) BuildCall(fn_ty: Type, fn: Value, args: *mut Array<Value>, name: string) -> Value;

/**
 * @brief Inbounds GEP (`LLVMBuildInBoundsGEP2`); packs `indices` to C array.
 * @param ty Aggregate type being indexed.
 * @param ptr Base pointer.
 * @param indices Index values (borrowed via `*mut`; caller owns the Array).
 * @param name Result name.
 */
pub method(Builder) BuildInBoundsGEP(ty: Type, ptr: Value, indices: *mut Array<Value>, name: string) -> Value;

/**
 * @brief Insert value into aggregate (`LLVMBuildInsertValue`).
 */
pub method(Builder) BuildInsertValue(agg: Value, elt: Value, idx: uint32, name: string) -> Value;

pub method(Builder) GetInsertBlock() -> BasicBlock;
pub method(Builder) BuildSub(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildMul(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildSDiv(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildUDiv(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildSRem(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildURem(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildAnd(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildOr(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildXor(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildShl(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildAShr(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildLShr(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildNeg(v: Value, name: string) -> Value;
pub method(Builder) BuildNot(v: Value, name: string) -> Value;
pub method(Builder) BuildFAdd(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFSub(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFMul(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFDiv(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFRem(lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFNeg(v: Value, name: string) -> Value;
pub method(Builder) BuildICmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildFCmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value;
pub method(Builder) BuildTrunc(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildSExt(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildZExt(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildFPTrunc(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildFPExt(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildSIToFP(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildFPToSI(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildBitCast(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildPtrToInt(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildIntToPtr(v: Value, dest: Type, name: string) -> Value;
pub method(Builder) BuildExtractValue(agg: Value, idx: uint32, name: string) -> Value;
pub method(Builder) BuildSelect(cond: Value, then_v: Value, else_v: Value, name: string) -> Value;
pub method(Builder) BuildSwitch(v: Value, else_bb: BasicBlock, num_cases: uint32) -> Value;
pub method(Builder) BuildPhi(ty: Type, name: string) -> Value;
pub method(Builder) BuildFence(ordering: int32, single_thread: int32, name: string) -> Value;
pub method(Builder) BuildAtomicRMW(op: int32, ptr: Value, val: Value, ordering: int32, single_thread: int32) -> Value;
pub method(Builder) BuildAtomicCmpXchg(ptr: Value, cmp: Value, new_v: Value, success_ordering: int32, failure_ordering: int32, single_thread: int32) -> Value;

/** `LLVMAtomicRMWBinOp` (Core.h). */
pub static kAtomicRmwXchg: int32 = 0;
pub static kAtomicRmwAdd: int32 = 1;
pub static kAtomicRmwSub: int32 = 2;
pub static kAtomicRmwAnd: int32 = 3;
pub static kAtomicRmwOr: int32 = 5;
pub static kAtomicRmwXor: int32 = 6;

/** `LLVMAtomicOrderingSequentiallyConsistent`. */
pub static kAtomicOrderingSeqCst: int32 = 7;
/** `LLVMAtomicOrderingAcquire`. */
pub static kAtomicOrderingAcquire: int32 = 4;
/** `LLVMAtomicOrderingRelease`. */
pub static kAtomicOrderingRelease: int32 = 5;
/** `LLVMAtomicOrderingAcquireRelease`. */
pub static kAtomicOrderingAcqRel: int32 = 6;
/** `LLVMAtomicOrderingMonotonic` (Relaxed). */
pub static kAtomicOrderingMonotonic: int32 = 2;

pub static kICmpEQ: int32 = 32;
pub static kICmpNE: int32 = 33;
pub static kICmpUGT: int32 = 34;
pub static kICmpUGE: int32 = 35;
pub static kICmpULT: int32 = 36;
pub static kICmpULE: int32 = 37;
pub static kICmpSGT: int32 = 38;
pub static kICmpSGE: int32 = 39;
pub static kICmpSLT: int32 = 40;
pub static kICmpSLE: int32 = 41;
pub static kFCmpOEQ: int32 = 1;
pub static kFCmpOGT: int32 = 2;
pub static kFCmpOGE: int32 = 3;
pub static kFCmpOLT: int32 = 4;
pub static kFCmpOLE: int32 = 5;
pub static kFCmpONE: int32 = 6;
/** LLVM real unordered-or-not-equal predicate (`LLVMRealUNE`). */
pub static kFCmpUNE: int32 = 14;
