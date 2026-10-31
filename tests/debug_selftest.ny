// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief Debug state remains inert when empty and retains DWARF metadata during a live module. */
part of LlvmTests;

@test func test_llvm_empty_debug_handle_is_inert() {
  var debug: DebugInfo = DebugInfo{};
  AssertTrue(!debug.IsValid());
  debug.SetLocation(Builder{}, 1);
  debug.Declare(Builder{}, Value{}, "x", "int32", 1, 0);
  debug.Finalize();
  debug.Dispose();
  debug.Dispose();
  AssertTrue(!debug.IsValid());
}

@test func test_llvm_debug_handle_finalizes_before_module_release() {
  let context: Context = Context.Create();
  let mod: Module = Module.Create(context, "debug-owner");
  let builder: Builder = Builder.Create(context);
  var parameters: Array<Type> = Array<Type>{};
  let function: Value = mod.AddFunction("debug_function", Type.Function(context.VoidType(), &mut parameters, 0));
  let entry: BasicBlock = context.AppendBasicBlock(function, "entry");
  builder.PositionAtEnd(entry);

  var debug: DebugInfo = DebugInfo.New(context, mod, "debug-owner.ny", false);
  AssertTrue(debug.IsValid());
  debug.AttachFunction(function, "debug_function", 1, false);
  debug.SetLocation(builder, 2);
  builder.BuildRetVoid();
  debug.Finalize();
  AssertEqI32(mod.Verify(), 0);
  let created: Result<Directory, IoError> = Directory.SystemTemp().CreateTemp("nyra-debug-owner-");
  AssertTrue(created.IsOk());
  let directory: Directory = created.get_if<Directory>() as Directory;
  let path: string = Path.Join(directory.Path(), "debug.ll");
  AssertEqI32(mod.WriteIR(path), 0);
  let loaded: Result<string, IoError> = File.New(path).ReadAsString();
  AssertTrue(loaded.IsOk());
  let text: string = loaded.get_if<string>() as string;
  AssertTrue(text.Contains("DICompileUnit"));
  AssertTrue(text.Contains("DILocation"));

  debug.Dispose();
  AssertTrue(!debug.IsValid());
  debug.Dispose();
  builder.Dispose();
  mod.Dispose();
  context.Dispose();
  AssertTrue(directory.DeleteRecursive().IsOk());
}

@test func test_llvm_empty_dwarf_builder_is_inert() {
  var debug: DwarfBuilder = DwarfBuilder{};
  AssertTrue(!debug.IsValid());
  debug.DiscardPending();
  debug.Finalize();
  debug.Dispose();
  debug.Dispose();
  AssertTrue(!debug.IsValid());
}

@test func test_llvm_dwarf_builder_move_retains_pending_and_isolates_owners() {
  let context: Context = Context.Create();
  let mod: Module = Module.Create(context, "dwarf-provider-owner");
  var first: DwarfBuilder = DwarfBuilder.New(mod.handle);
  var second: DwarfBuilder = DwarfBuilder.New(mod.handle);
  AssertTrue(first.IsValid());
  AssertTrue(second.IsValid());
  let filename: string = "owner.ny";
  let directory: string = ".";
  let name: string = "Node";
  let file: *mut void = first.CreateFile(
    filename.data as *const int8, filename.length as uintptr,
    directory.data as *const int8, directory.length as uintptr
  );
  let pending: *mut void = first.CompositeBegin(
    file, file, name.data as *const int8, name.length as uintptr,
    1u32, 64u64, 64u32, 0u32
  );
  AssertTrue(pending != (0 as *mut void));
  AssertTrue(second.CompositeEnd(pending) == (0 as *mut void));
  var moved: DwarfBuilder = move(first);
  first = DwarfBuilder{};
  AssertTrue(!first.IsValid());
  first.DiscardPending();
  AssertTrue(moved.CompositeEnd(pending) != (0 as *mut void));
  AssertTrue(moved.CompositeEnd(pending) == (0 as *mut void));
  moved.Finalize();
  moved.Dispose();
  moved.Dispose();
  second.Finalize();
  second.Dispose();
  mod.Dispose();
  context.Dispose();
}

@test func test_llvm_inline_debug_owner_move_preserves_live_metadata() {
  let context: Context = Context.Create();
  let mod: Module = Module.Create(context, "inline-debug-owner");
  var original: DebugInfo = DebugInfo.New(context, mod, "inline.ny", false);
  AssertTrue(original.IsValid());
  var transferred: DebugInfo = move(original);
  original = DebugInfo{};
  original.Dispose();
  AssertTrue(transferred.IsValid());
  transferred.Finalize();
  AssertEqI32(mod.Verify(), 0);
  transferred.Dispose();
  transferred.Dispose();
  AssertTrue(!transferred.IsValid());
  mod.Dispose();
  context.Dispose();
}
