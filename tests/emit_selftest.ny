/**
 * @brief EmitObject hello_puts smoke: build main+puts IR, emit .o, clang link, run.
 * @note Parity class = tests/compiler/fixtures/lang/hello_puts (stdout `hello\n`, exit 0).
 * @note DWARF omitted (nyra-llvm.md §1.5.2 / p2 defer).
 * @see m_v0.7_p7 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief Host `system(3)` for clang link + run of the emitted object.
 */
@extern("C") func system(command: *const int8) -> int32;

/** LLVMPrivateLinkage enum value (`LLVMLinkage` in Core.h). */
static kLlvmPrivateLinkage: int32 = 9;

/**
 * @brief Build hello_puts-equivalent IR, EmitObject, host-clang link, run; exit 0 + stdout hello.
 */
@test
func test_llvm_emit_object_hello_puts() {
  let tmp_root: Directory = Directory.SystemTemp();
  let temp_r: Result<Directory, IoError> = tmp_root.CreateTemp("nyra_llvm_p7_");
  AssertTrue(temp_r.IsOk());
  let dir_opt: Directory? = temp_r.get_if<Directory>();
  AssertTrue(dir_opt != nil);
  let dir: Directory = dir_opt as Directory;
  let dir_path: string = dir.Path();
  let obj_path: string = Path.Join(dir_path, "hello_puts.o");
  let exe_path: string = Path.Join(dir_path, "hello_puts");
  let out_path: string = Path.Join(dir_path, "stdout.txt");

  let ctx: Context = Context.Create();
  let mod: Module = Module.Create(ctx, "hello_puts");
  let i8t: Type = ctx.Int8Type();
  let i32t: Type = ctx.Int32Type();
  let ptr_i8: Type = Type.Pointer(i8t);

  // declare i32 @puts(ptr)
  var puts_params: Array<Type> = Array<Type>{};
  puts_params.Push(ptr_i8);
  let puts_ty: Type = Type.Function(i32t, &mut puts_params, 0);
  let puts_fn: Value = mod.AddFunction("puts", puts_ty);

  // define i32 @main()
  var main_params: Array<Type> = Array<Type>{};
  let main_ty: Type = Type.Function(i32t, &mut main_params, 0);
  let main_fn: Value = mod.AddFunction("main", main_ty);
  let entry: BasicBlock = ctx.AppendBasicBlock(main_fn, "entry");
  let bld: Builder = Builder.Create(ctx);
  bld.PositionAtEnd(entry);

  let msg: string = "hello";
  let init: Value = ctx.ConstString(msg, 1);
  // ConstString(+NUL) → [6 x i8]
  let arr_ty: Type = Type.Array(i8t, (msg.length + 1) as uint32);
  let gv: Value = mod.AddGlobal(arr_ty, ".str");
  gv.SetInitializer(init);
  gv.SetLinkage(kLlvmPrivateLinkage);
  gv.SetGlobalConstant(1);

  let zero: Value = Value.ConstInt(i32t, 0 as uint64, 0);
  var idxs: Array<Value> = Array<Value>{};
  idxs.Push(zero);
  idxs.Push(zero);
  let str_ptr: Value = bld.BuildInBoundsGEP(arr_ty, gv, &mut idxs, "str.gep");

  var call_args: Array<Value> = Array<Value>{};
  call_args.Push(str_ptr);
  bld.BuildCall(puts_ty, puts_fn, &mut call_args, "puts.call");
  bld.BuildRet(zero);

  AssertEqI32(mod.Verify(), 0);
  AssertEqI32(mod.EmitObject(obj_path), 0);
  AssertTrue(File.New(obj_path).Exists());

  // Same host linker as Go LinkUnit: /usr/bin/clang -o <exe> <obj>
  // (hello_puts needs only libc `puts`; Go also appends libnyra_platform.a when hosted.)
  let link_cmd: string = "/usr/bin/clang -o ".Concat(exe_path).Concat(" ").Concat(obj_path);
  AssertEqI32(system(link_cmd.data as *const int8), 0);
  AssertTrue(File.New(exe_path).Exists());

  let run_cmd: string = exe_path.Concat(" > ").Concat(out_path);
  AssertEqI32(system(run_cmd.data as *const int8), 0);

  let rd: Result<string, IoError> = File.New(out_path).ReadAsString();
  AssertTrue(rd.IsOk());
  let got_opt: string? = rd.get_if<string>();
  AssertTrue(got_opt != nil);
  AssertEqString(got_opt as string, "hello\n");

  bld.Dispose();
  mod.Dispose();
  ctx.Dispose();

  let _cleanup: Result<Unit, IoError> = dir.DeleteRecursive();
}
