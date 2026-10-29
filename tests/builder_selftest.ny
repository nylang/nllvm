// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

part of LlvmTests;

/**
 * @brief IRBuilder / Module.Verify smokes: i32 add(i32,i32) OK + missing terminator fail.
 * @note Dispose Context / Module / Builder; values/BBs die with the module.
 * @see m_v0.7_p6 · m_v0.6_p2 Record
 */

/**
 * @brief Build `i32 add(i32, i32)` with alloca/load/store/add/ret; Verify succeeds.
 */
@test
func test_llvm_add_module_verify_ok() {
  let ctx: Context = Context.Create();
  AssertTrue(ctx.handle != (0 as *mut void));

  let mod: Module = Module.Create(ctx, "add_mod");
  AssertTrue(mod.handle != (0 as *mut void));

  let i32t: Type = ctx.Int32Type();
  AssertTrue(i32t.handle != (0 as *mut void));

  var params: Array<Type> = Array<Type>{};
  params.Push(i32t);
  params.Push(i32t);
  let fn_ty: Type = Type.Function(i32t, &mut params, 0);
  AssertTrue(fn_ty.handle != (0 as *mut void));

  let fn: Value = mod.AddFunction("add", fn_ty);
  AssertTrue(fn.handle != (0 as *mut void));

  let entry: BasicBlock = ctx.AppendBasicBlock(fn, "entry");
  AssertTrue(entry.handle != (0 as *mut void));

  let bld: Builder = Builder.Create(ctx);
  AssertTrue(bld.handle != (0 as *mut void));
  bld.PositionAtEnd(entry);

  let arg0: Value = fn.Param(0);
  let arg1: Value = fn.Param(1);
  let a_addr: Value = bld.BuildAlloca(i32t, "a.addr");
  let b_addr: Value = bld.BuildAlloca(i32t, "b.addr");
  bld.BuildStore(arg0, a_addr);
  bld.BuildStore(arg1, b_addr);
  let a_val: Value = bld.BuildLoad(i32t, a_addr, "a");
  let b_val: Value = bld.BuildLoad(i32t, b_addr, "b");
  let sum: Value = bld.BuildAdd(a_val, b_val, "sum");
  bld.BuildRet(sum);

  AssertEqI32(mod.Verify(), 0);

  bld.Dispose();
  mod.Dispose();
  ctx.Dispose();
}

/**
 * @brief Function with a BB but no terminator → Verify returns nonzero.
 */
@test
func test_llvm_module_verify_fail_missing_terminator() {
  let ctx: Context = Context.Create();
  let mod: Module = Module.Create(ctx, "bad_mod");
  let i32t: Type = ctx.Int32Type();
  var params: Array<Type> = Array<Type>{};
  let fn_ty: Type = Type.Function(i32t, &mut params, 0);
  let fn: Value = mod.AddFunction("bad", fn_ty);
  let entry: BasicBlock = ctx.AppendBasicBlock(fn, "entry");
  let bld: Builder = Builder.Create(ctx);
  bld.PositionAtEnd(entry);
  // Intentionally no BuildRet / BuildBr — missing terminator.

  AssertTrue(mod.Verify() != 0);

  bld.Dispose();
  mod.Dispose();
  ctx.Dispose();
}

/**
 * @brief v1 type surface used by later hello IR (Pointer / Array / Struct / Void / ints).
 */
@test
func test_llvm_v1_types_smoke() {
  let ctx: Context = Context.Create();
  let i1t: Type = ctx.Int1Type();
  let i8t: Type = ctx.Int8Type();
  let i32t: Type = ctx.Int32Type();
  let i64t: Type = ctx.Int64Type();
  let void_t: Type = ctx.VoidType();
  AssertTrue(i1t.handle != (0 as *mut void));
  AssertTrue(i8t.handle != (0 as *mut void));
  AssertTrue(i32t.handle != (0 as *mut void));
  AssertTrue(i64t.handle != (0 as *mut void));
  AssertTrue(void_t.handle != (0 as *mut void));

  let ptr_i8: Type = Type.Pointer(i8t);
  AssertTrue(ptr_i8.handle != (0 as *mut void));

  let arr: Type = Type.Array(i32t, 4 as uint32);
  AssertTrue(arr.handle != (0 as *mut void));

  var fields: Array<Type> = Array<Type>{};
  fields.Push(ptr_i8);
  fields.Push(i32t);
  fields.Push(i32t);
  let anon: Type = ctx.StructType(&mut fields, 0);
  AssertTrue(anon.handle != (0 as *mut void));

  let named: Type = ctx.StructCreateNamed("NyraString");
  AssertTrue(named.handle != (0 as *mut void));
  var body: Array<Type> = Array<Type>{};
  body.Push(ptr_i8);
  body.Push(i32t);
  body.Push(i32t);
  named.StructSetBody(&mut body, 0);

  ctx.Dispose();
}

@test
func test_llvm_icmp_switch_verify_ok() {
  let ctx: Context = Context.Create();
  let mod: Module = Module.Create(ctx, "icmp_sw");
  let i32t: Type = ctx.Int32Type();
  var params: Array<Type> = Array<Type>{};
  params.Push(i32t);
  let fn_ty: Type = Type.Function(i32t, &mut params, 0);
  let fn: Value = mod.AddFunction("f", fn_ty);
  let entry: BasicBlock = ctx.AppendBasicBlock(fn, "entry");
  let then_bb: BasicBlock = ctx.AppendBasicBlock(fn, "then");
  let else_bb: BasicBlock = ctx.AppendBasicBlock(fn, "else");
  let bld: Builder = Builder.Create(ctx);
  bld.PositionAtEnd(entry);
  let a: Value = fn.Param(0);
  let z: Value = Value.ConstInt(i32t, 0 as uint64, 0);
  let cmp: Value = bld.BuildICmp(kICmpEQ, a, z, "eq");
  bld.BuildCondBr(cmp, then_bb, else_bb);
  bld.PositionAtEnd(then_bb);
  bld.BuildRet(Value.ConstInt(i32t, 1 as uint64, 0));
  bld.PositionAtEnd(else_bb);
  let merge: BasicBlock = ctx.AppendBasicBlock(fn, "sw.merge");
  let c0: BasicBlock = ctx.AppendBasicBlock(fn, "c0");
  let sw: Value = bld.BuildSwitch(a, merge, 1 as uint32);
  sw.AddCase(Value.ConstInt(i32t, 2 as uint64, 1), c0);
  bld.PositionAtEnd(c0);
  bld.BuildRet(Value.ConstInt(i32t, 2 as uint64, 0));
  bld.PositionAtEnd(merge);
  bld.BuildRet(z);
  AssertEqI32(mod.Verify(), 0);
  bld.Dispose();
  mod.Dispose();
  ctx.Dispose();
}
