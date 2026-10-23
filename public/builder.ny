/**
 * @brief Open layout and IRBuilder methods (alloca/load/store/add/ret/br).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief Opaque wrapper: `handle` holds `LLVMBuilderRef` as `*mut void`.
 */
pub struct Builder {
  handle: *mut void;
}

/**
 * @brief `LLVMCreateBuilderInContext`.
 */
pub static method(Builder) Create(ctx: Context) -> Builder {
  let handle: *mut void = LLVMCreateBuilderInContext(ctx.handle);
  return Builder{ handle: handle };
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
 * @brief Hoist alloca into function entry before first instruction (peer Go createEntryAlloca).
 * @note Sequential calls reverse order in the entry block — matches Go FirstInstruction insert.
 */
pub method(Builder) BuildEntryAlloca(fn: Value, ty: Type, name: string) -> Value {
  return self.BuildEntryAllocaInit(fn, ty, name, Value{ handle: 0 as *mut void });
}

/**
 * @brief Peer Go `createEntryAllocaInit` — optional null/zero store immediately after alloca
 *        while still inserted before the entry's first instruction (interleaves with later allocas).
 * @param init_val When `handle != null`, `store init_val, alloca` before restoring insert point.
 */
pub method(Builder) BuildEntryAllocaInit(fn: Value, ty: Type, name: string, init_val: Value) -> Value {
  let cur: *mut void = LLVMGetInsertBlock(self.handle);
  let entry: *mut void = LLVMGetEntryBasicBlock(fn.handle);
  let first: *mut void = LLVMGetFirstInstruction(entry);
  if first == (0 as *mut void) {
    LLVMPositionBuilderAtEnd(self.handle, entry);
  } else {
    LLVMPositionBuilderBefore(self.handle, first);
  }
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildAlloca(self.handle, ty.handle, (&mut cname[0]) as *const int8);
  let slot: Value = Value{ handle: handle };
  if init_val.handle != (0 as *mut void) {
    let _st: *mut void = LLVMBuildStore(self.handle, init_val.handle, handle);
  }
  if cur != (0 as *mut void) {
    LLVMPositionBuilderAtEnd(self.handle, cur);
  }
  return slot;
}

/**
 * @brief `LLVMBuildAlloca`.
 */
pub method(Builder) BuildAlloca(ty: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildAlloca(self.handle, ty.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildArrayAlloca(ty: Type, count: Value, name: string) -> Value {
  if self.handle == (0 as *mut void) || ty.handle == (0 as *mut void) || count.handle == (0 as *mut void) {
    return Value{handle: 0 as *mut void};
  }
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildArrayAlloca(self.handle, ty.handle, count.handle, (&mut cname[0]) as *const int8);
  return Value{handle: handle};
}

/**
 * @brief `LLVMBuildLoad2` (product name `BuildLoad`).
 */
pub method(Builder) BuildLoad(ty: Type, ptr: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildLoad2(self.handle, ty.handle, ptr.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildStore`.
 */
pub method(Builder) BuildStore(val: Value, ptr: Value) -> Value {
  let handle: *mut void = LLVMBuildStore(self.handle, val.handle, ptr.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildAdd`.
 */
pub method(Builder) BuildAdd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildAdd(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildRet`.
 */
pub method(Builder) BuildRet(v: Value) -> Value {
  let handle: *mut void = LLVMBuildRet(self.handle, v.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildRetVoid`.
 */
pub method(Builder) BuildUnreachable() -> Value {
  let handle: *mut void = LLVMBuildUnreachable(self.handle);
  return Value{ handle: handle };
}

pub method(Builder) BuildRetVoid() -> Value {
  let handle: *mut void = LLVMBuildRetVoid(self.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildBr`.
 */
pub method(Builder) BuildBr(dest: BasicBlock) -> Value {
  let handle: *mut void = LLVMBuildBr(self.handle, dest.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildCondBr`.
 */
pub method(Builder) BuildCondBr(cond: Value, then_bb: BasicBlock, else_bb: BasicBlock) -> Value {
  let handle: *mut void = LLVMBuildCondBr(self.handle, cond.handle, then_bb.handle, else_bb.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildCall2` with Nyra `Array` → C pointer+count.
 */
pub method(Builder) BuildCall(fn_ty: Type, fn: Value, args: *mut Array<Value>, name: string) -> Value {
  unsafe {
    // Peer Module.llvm_cstr_buf — LLVM C API requires NUL-terminated Name.
    var cname_buf: owned <int8>[] = llvm_cstr_buf(name);
    let cname: *const int8 = (&mut cname_buf[0]) as *const int8;
    let n: int32 = (*args).len;
    if n <= 0 {
      let handle: *mut void = LLVMBuildCall2(
        self.handle, fn_ty.handle, fn.handle, 0 as *mut void, 0 as uint32, cname
      );
      return Value{ handle: handle };
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
    return Value{ handle: handle };
  }
}

/**
 * @brief `LLVMBuildInBoundsGEP2` with Nyra `Array` → C pointer+count.
 */
pub method(Builder) BuildInBoundsGEP(ty: Type, ptr: Value, indices: *mut Array<Value>, name: string) -> Value {
  unsafe {
    let n: int32 = (*indices).len;
    var cname: owned <int8>[] = llvm_cstr_buf(name);
    if n <= 0 {
      let handle: *mut void = LLVMBuildInBoundsGEP2(
        self.handle, ty.handle, ptr.handle, 0 as *mut void, 0 as uint32, (&mut cname[0]) as *const int8
      );
      return Value{ handle: handle };
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
      self.handle, ty.handle, ptr.handle, idx_refs, n as uint32, (&mut cname[0]) as *const int8
    );
    return Value{ handle: handle };
  }
}

/**
 * @brief `LLVMBuildInsertValue`.
 */
pub method(Builder) BuildInsertValue(agg: Value, elt: Value, idx: uint32, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildInsertValue(self.handle, agg.handle, elt.handle, idx, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) GetInsertBlock() -> BasicBlock {
  let handle: *mut void = LLVMGetInsertBlock(self.handle);
  return BasicBlock{ handle: handle };
}

pub method(Builder) BuildSub(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSub(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildMul(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildMul(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSDiv(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildUDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildUDiv(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSRem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSRem(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildURem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildURem(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildAnd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildAnd(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildOr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildOr(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildXor(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildXor(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildShl(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildShl(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildAShr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildAShr(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildLShr(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildLShr(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildNeg(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildNeg(self.handle, v.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildNot(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildNot(self.handle, v.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFAdd(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFAdd(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFSub(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFSub(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFMul(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFMul(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFDiv(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFDiv(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFRem(lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFRem(self.handle, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFNeg(v: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFNeg(self.handle, v.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildICmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildICmp(self.handle, pred, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFCmp(pred: int32, lhs: Value, rhs: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFCmp(self.handle, pred, lhs.handle, rhs.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildTrunc(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildTrunc(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSExt(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildZExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildZExt(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFPTrunc(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFPTrunc(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFPExt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFPExt(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSIToFP(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSIToFP(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildUIToFP(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildUIToFP(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFPToSI(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFPToSI(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildFPToUI(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFPToUI(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildBitCast(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildBitCast(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildPtrToInt(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildPtrToInt(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildIntToPtr(v: Value, dest: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildIntToPtr(self.handle, v.handle, dest.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildExtractValue(agg: Value, idx: uint32, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildExtractValue(self.handle, agg.handle, idx, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSelect(cond: Value, then_v: Value, else_v: Value, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildSelect(self.handle, cond.handle, then_v.handle, else_v.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

pub method(Builder) BuildSwitch(v: Value, else_bb: BasicBlock, num_cases: uint32) -> Value {
  let handle: *mut void = LLVMBuildSwitch(self.handle, v.handle, else_bb.handle, num_cases);
  return Value{ handle: handle };
}

pub method(Builder) BuildPhi(ty: Type, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildPhi(self.handle, ty.handle, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildFence` — peer Go `CreateFence` (SeqCst = 7).
 */
pub method(Builder) BuildFence(ordering: int32, single_thread: int32, name: string) -> Value {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMBuildFence(self.handle, ordering, single_thread, (&mut cname[0]) as *const int8);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildAtomicRMW` — peer Go `CreateAtomicRMW`.
 */
pub method(Builder) BuildAtomicRMW(op: int32, ptr: Value, val: Value, ordering: int32, single_thread: int32) -> Value {
  let handle: *mut void = LLVMBuildAtomicRMW(self.handle, op, ptr.handle, val.handle, ordering, single_thread);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMBuildAtomicCmpXchg` — peer Go `CreateAtomicCmpXchg`.
 */
pub method(Builder) BuildAtomicCmpXchg(ptr: Value, cmp: Value, new_v: Value, success_ordering: int32, failure_ordering: int32, single_thread: int32) -> Value {
  let handle: *mut void = LLVMBuildAtomicCmpXchg(
    self.handle, ptr.handle, cmp.handle, new_v.handle, success_ordering, failure_ordering, single_thread
  );
  return Value{ handle: handle };
}

