// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmBuilder;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "interface/builder.ni";

/**
 * @brief Open layout and IRBuilder methods (alloca/load/store/add/ret/br).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

/**
 * @brief Create a builder in `ctx` (`LLVMCreateBuilderInContext`).
 * @returns The Builder value described above, retaining the documented ownership and
 *   default-state semantics.
 */
pub static method(Builder) Create(ctx: Context) -> Builder {
  let handle: *mut void = LLVMCreateBuilderInContext(ctx.handle);

  return Builder{handle: handle};
}

/**
 * @brief `LLVMDisposeBuilder(self.handle)`. Does not `nyra_free`.
 */
pub method(Builder) Dispose() -> void {
  LLVMDisposeBuilder(self.handle);
}

/**
 * @brief `LLVMPositionBuilderAtEnd`.
 */
pub method(Builder) PositionAtEnd(bb: BasicBlock) -> void {
  LLVMPositionBuilderAtEnd(self.handle, bb.handle);
}

/**
 * @brief `LLVMPositionBuilderBefore`.
 */
pub method(Builder) PositionBefore(instr: Value) -> void {
  LLVMPositionBuilderBefore(self.handle, instr.handle);
}

/**
 * @brief Alloca in `fn`'s entry block before the first instruction (Go createEntryAlloca).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildEntryAlloca(fn: Value, ty: Type, name: string) -> Value {
  return self.BuildEntryAllocaInit(fn, ty, name, Value{handle: 0 as *mut void});
}

/**
 * @brief Entry alloca + optional immediate store (Go `createEntryAllocaInit`).
 * @param init_val Null handle skips the store; otherwise `store init_val` before restoring IP.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildEntryAllocaInit(fn: Value, ty: Type, name: string, init_val: Value) -> Value {
  let cur: *mut void = LLVMGetInsertBlock(self.handle);
  let entry: *mut void = LLVMGetEntryBasicBlock(fn.handle);
  let first: *mut void = LLVMGetFirstInstruction(entry);
  if first == nil {
    LLVMPositionBuilderAtEnd(self.handle, entry);
  } else {
    LLVMPositionBuilderBefore(self.handle, first);
  }

  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildAlloca(self.handle, ty.handle,(&mut cname[0]) as *const int8);
  let slot: Value = Value{handle: handle};
  if init_val.handle != nil {
    let _st: *mut void = LLVMBuildStore(self.handle, init_val.handle, handle);
  }

  if cur != nil {
    LLVMPositionBuilderAtEnd(self.handle, cur);
  }

  return slot;
}

/**
 * @brief Stack alloca (`LLVMBuildAlloca`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildAlloca(ty: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildAlloca(self.handle, ty.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Allocate count elements of the given type in the current stack frame.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildArrayAlloca(ty: Type, count: Value, name: string) -> Value {
  if self.handle == nil || ty.handle == nil || count.handle == nil {
    return Value{handle: 0 as *mut void};
  }

  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildArrayAlloca(
    self.handle,
    ty.handle,
    count.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Typed load (`LLVMBuildLoad2`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildLoad(ty: Type, ptr: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildLoad2(self.handle, ty.handle, ptr.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Store (`LLVMBuildStore`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildStore(val: Value, ptr: Value) -> Value {
  let handle: *mut void = LLVMBuildStore(self.handle, val.handle, ptr.handle);

  return Value{handle: handle};
}

/**
 * @brief Integer add (`LLVMBuildAdd`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildAdd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildAdd(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Return a value (`LLVMBuildRet`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildRet(v: Value) -> Value {
  let handle: *mut void = LLVMBuildRet(self.handle, v.handle);

  return Value{handle: handle};
}

/**
 * @brief Unreachable terminator (`LLVMBuildUnreachable`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildUnreachable() -> Value {
  let handle: *mut void = LLVMBuildUnreachable(self.handle);

  return Value{handle: handle};
}

/**
 * @brief Void return (`LLVMBuildRetVoid`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildRetVoid() -> Value {
  let handle: *mut void = LLVMBuildRetVoid(self.handle);

  return Value{handle: handle};
}

/**
 * @brief Unconditional branch (`LLVMBuildBr`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildBr(dest: BasicBlock) -> Value {
  let handle: *mut void = LLVMBuildBr(self.handle, dest.handle);

  return Value{handle: handle};
}

/**
 * @brief Conditional branch (`LLVMBuildCondBr`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildCondBr(cond: Value, then_bb: BasicBlock, else_bb: BasicBlock) -> Value {
  let handle: *mut void = LLVMBuildCondBr(self.handle, cond.handle, then_bb.handle, else_bb.handle);

  return Value{handle: handle};
}

/**
 * @brief Call (`LLVMBuildCall2`); packs `args` to `LLVMValueRef*` + count.
 * @param fn_ty Function type.
 * @param fn Callee value.
 * @param args Call arguments (borrowed via `*mut`; caller owns the Array).
 * @param name Result name (empty OK for void).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildCall(fn_ty: Type, fn: Value, args: *mut Array<Value>, name: string) -> Value {
  unsafe {
    // Peer Module.llvm_cstr_buf — LLVM C API requires NUL-terminated Name.
    var cname_buf: owned <int8>[] = name.ToCStringBytes();
    let cname: *const int8 = (&mut cname_buf[0]) as *const int8;
    let n: int32 = (*args).len;
    if n <= 0 {
      let handle: *mut void = LLVMBuildCall2(
        self.handle, fn_ty.handle, fn.handle, 0 as *mut void, 0u32, cname
      );

      return Value{handle: handle};
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*args).buf[i];
      refs[i] = v.handle;
      i = i + 1;
    }

    let arg_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMBuildCall2(
      self.handle, fn_ty.handle, fn.handle, arg_refs, n as uint32, cname
    );

    return Value{handle: handle};
  }
}

/**
 * @brief Inbounds GEP (`LLVMBuildInBoundsGEP2`); packs `indices` to C array.
 * @param ty Aggregate type being indexed.
 * @param ptr Base pointer.
 * @param indices Index values (borrowed via `*mut`; caller owns the Array).
 * @param name Result name.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildInBoundsGEP(
  ty: Type,
  ptr: Value,
  indices: *mut Array<Value>,
  name: string
) -> Value {
  unsafe {
    let n: int32 = (*indices).len;
    var cname: owned <int8>[] = name.ToCStringBytes();
    if n <= 0 {
      let handle: *mut void = LLVMBuildInBoundsGEP2(
        self.handle, ty.handle, ptr.handle, 0 as *mut void, 0u32,(&mut cname[0]) as *const int8
      );

      return Value{handle: handle};
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*indices).buf[i];
      refs[i] = v.handle;
      i = i + 1;
    }

    let idx_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMBuildInBoundsGEP2(
      self.handle, ty.handle, ptr.handle, idx_refs, n as uint32,(&mut cname[0]) as *const int8
    );

    return Value{handle: handle};
  }
}

/**
 * @brief Insert value into aggregate (`LLVMBuildInsertValue`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Builder) BuildInsertValue(agg: Value, elt: Value, idx: uint32, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildInsertValue(
    self.handle,
    agg.handle,
    elt.handle,
    idx,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Borrow the current insertion block without changing builder position.
 * @returns Borrowed LLVM block handle; no ownership transfer.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) GetInsertBlock() -> BasicBlock {
  let handle: *mut void = LLVMGetInsertBlock(self.handle);

  return BasicBlock{handle: handle};
}

/**
 * @brief Build integer subtraction of the two operands.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSub(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSub(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build integer multiplication of the two operands.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildMul(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildMul(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build signed integer division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSDiv(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build unsigned integer division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildUDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildUDiv(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build signed integer remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSRem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSRem(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build unsigned integer remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildURem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildURem(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build bitwise conjunction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAnd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildAnd(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build bitwise disjunction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildOr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildOr(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build bitwise exclusive-or.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildXor(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildXor(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build a left shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildShl(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildShl(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build a sign-propagating right shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildAShr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildAShr(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build a zero-filling right shift.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildLShr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildLShr(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build integer negation.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildNeg(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildNeg(self.handle, v.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build bitwise complement.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildNot(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildNot(self.handle, v.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point addition.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFAdd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFAdd(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point subtraction.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFSub(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFSub(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point multiplication.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFMul(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFMul(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point division.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFDiv(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point remainder.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFRem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFRem(self.handle, lhs.handle, rhs.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build floating-point negation.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFNeg(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFNeg(self.handle, v.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Compare integer operands with the supplied LLVM integer predicate.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildICmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildICmp(
    self.handle,
    pred,
    lhs.handle,
    rhs.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Compare floating operands with the supplied LLVM real predicate.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFCmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFCmp(
    self.handle,
    pred,
    lhs.handle,
    rhs.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Truncate an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildTrunc(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildTrunc(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Sign-extend an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSExt(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Zero-extend an integer to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildZExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildZExt(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Narrow a floating value to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPTrunc(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFPTrunc(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Widen a floating value to the destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFPExt(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convert a signed integer to floating point.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSIToFP(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSIToFP(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convert an unsigned LLVM integer value to floating point.
 * @returns Result value in this builder context; emitted instructions belong to its module.
 */
pub method(Builder) BuildUIToFP(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildUIToFP(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convert a floating value to a signed integer.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFPToSI(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFPToSI(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convert an LLVM floating value to an unsigned integer.
 * @returns Result value under LLVM floating-to-integer range/poison semantics.
 */
pub method(Builder) BuildFPToUI(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFPToUI(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Reinterpret a value using an LLVM-compatible destination type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildBitCast(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildBitCast(self.handle, v.handle, dest.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convert a pointer value to an integer type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildPtrToInt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildPtrToInt(
    self.handle,
    v.handle,
    dest.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Convert an integer value to a pointer type.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildIntToPtr(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildIntToPtr(
    self.handle,
    v.handle,
    dest.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Extract the aggregate element at the supplied zero-based index.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildExtractValue(agg: Value, idx: uint32, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildExtractValue(self.handle, agg.handle, idx,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Select between two values using an LLVM condition.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSelect(cond: Value, then_v: Value, else_v: Value, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildSelect(
    self.handle,
    cond.handle,
    then_v.handle,
    else_v.handle,
    (&mut cname[0]) as *const int8
  );

  return Value{handle: handle};
}

/**
 * @brief Build a switch terminator with a default destination and reserved case capacity.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildSwitch(v: Value, else_bb: BasicBlock, num_cases: uint32) -> Value {
  let handle: *mut void = LLVMBuildSwitch(self.handle, v.handle, else_bb.handle, num_cases);

  return Value{handle: handle};
}

/**
 * @brief Create a PHI node; populate its incoming values with Value.AddIncoming.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildPhi(ty: Type, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildPhi(self.handle, ty.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Build an atomic fence with the supplied ordering and thread scope.
 * @returns LLVM result handle owned by its enclosing context/module.
 * @note LLVM operand, type, insertion-point and ordering preconditions apply; the wrapper does
 *   not validate them.
 */
pub method(Builder) BuildFence(ordering: int32, single_thread: int32, name: string) -> Value {
  var cname: owned <int8>[] = name.ToCStringBytes();
  let handle: *mut void = LLVMBuildFence(self.handle, ordering, single_thread,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

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
) -> Value {
  let handle: *mut void = LLVMBuildAtomicRMW(
    self.handle,
    op,
    ptr.handle,
    val.handle,
    ordering,
    single_thread
  );

  return Value{handle: handle};
}

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
) -> Value {
  let handle: *mut void = LLVMBuildAtomicCmpXchg(
    self.handle, ptr.handle, cmp.handle, new_v.handle, success_ordering, failure_ordering, single_thread
  );

  return Value{handle: handle};
}
