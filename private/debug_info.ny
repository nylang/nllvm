// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmDebugInfo;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "interface/debug_info.ni";

/**
 * @brief Convenience DWARF state held inline; the caller retains module/context lifetime.
 * @note Owns only the foreign DIBuilder. Metadata handles borrow its LLVM context.
 */
pub struct DebugInfo {
  builder: *mut void;
  file: *mut void;
  unit: *mut void;
  signature: *mut void;
  function_scope: *mut void;
  context: *mut void;
  function: *mut void;
}

/**
 * @brief Create native DWARF builder state for a module and source path.
 * @returns A live debug handle, or an inert handle if native state allocation fails.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub static method(DebugInfo) New(ctx: Context, mod: Module, source_path: string, optimized: bool) -> DebugInfo {
  LLVMSetIsNewDbgInfoFormat(mod.handle, 1);
  var state: DebugInfo = DebugInfo{builder: LLVMCreateDIBuilder(mod.handle)};
  if !state.IsValid() {
    return move(state);
  }

  var path_buf: owned <int8>[] = source_path.ToCStringBytes();
  var producer: string = copy("Nyra compiler");
  var producer_buf: owned <int8>[] = producer.ToCStringBytes();
  var empty: string = "";
  var empty_buf: owned <int8>[] = empty.ToCStringBytes();
  let dib: *mut void = state.builder;
  let file: *mut void = LLVMDIBuilderCreateFile(
    dib,
    (&mut path_buf[0]) as *const int8,
    source_path.length as uintptr,
    (&mut empty_buf[0]) as *const int8,
    0up
  );
  var opt: int32 = 0;
  if optimized {
    opt = 1;
  }

  // LLVMDWARFSourceLanguageC99 == 11 (LLVM enum, not DW_LANG_C99).
  let cu: *mut void = LLVMDIBuilderCreateCompileUnit(
    dib,
    11u32,
    file,
    (&mut producer_buf[0]) as *const int8,
    producer.length as uintptr,
    opt,
    (&mut empty_buf[0]) as *const int8,
    0up,
    0u32,
    (&mut empty_buf[0]) as *const int8,
    0up,
    1u32,
    0u32,
    1,
    0,
    (&mut empty_buf[0]) as *const int8,
    0up,
    (&mut empty_buf[0]) as *const int8,
    0up
  );
  let subty: *mut void = LLVMDIBuilderCreateSubroutineType(
    dib,
    file,
    0 as *mut void,
    0u32,
    0u32
  );
  state.builder = dib;
  state.file = file;
  state.unit = cu;
  state.signature = subty;
  state.function_scope = 0 as *mut void;
  state.context = ctx.handle;
  state.function = 0 as *mut void;

  return move(state);
}

/**
 * @brief Attach a source-level function scope and retain it as the current debug scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) AttachFunction(
  fn_value: Value,
  name: string,
  line: int32,
  optimized: bool
) -> void {
  let dib: *mut void = self.builder;
  if dib == nil {
    return;
  }

  var name_buf: owned <int8>[] = name.ToCStringBytes();
  var opt: int32 = 0;
  if optimized {
    opt = 1;
  }

  var ln: uint32 = 1;
  if line > 0 {
    ln = line as uint32;
  }

  let file: *mut void = self.file;
  let subty: *mut void = self.signature;
  let sp: *mut void = LLVMDIBuilderCreateFunction(
    dib,
    file,
    (&mut name_buf[0]) as *const int8,
    name.length as uintptr,
    (&mut name_buf[0]) as *const int8,
    name.length as uintptr,
    file,
    ln,
    subty,
    0,
    1,
    ln,
    0u32,
    opt
  );
  LLVMSetSubprogram(fn_value.handle, sp);
  self.function_scope = sp;
  self.function = fn_value.handle;
}

/**
 * @brief Set builder location within the current debug function scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) SetLocation(builder: Builder, line: int32) -> void {
  if !self.IsValid() || builder.handle == nil {
    return;
  }

  let dib: *mut void = self.builder;
  let sp: *mut void = self.function_scope;
  let block: *mut void = LLVMGetInsertBlock(builder.handle);
  let fn_value: *mut void = self.function;
  if (dib == nil)
    || (sp == nil)
    || (block == nil)
    || (LLVMGetBasicBlockParent(block) != fn_value)
    || (line <= 0) {
    return;
  }

  let ctx: *mut void = self.context;
  let loc: *mut void = LLVMDIBuilderCreateDebugLocation(ctx, line as uint32, 1u32, sp, 0 as *mut void);
  LLVMSetCurrentDebugLocation2(builder.handle, loc);
}

// Map source spellings to the limited debug type vocabulary without changing the lowered LLVM value type.
method(DebugInfo) Type(typ: string) -> *mut void {
  let dib: *mut void = self.builder;
  var name_buf: owned <int8>[] = typ.ToCStringBytes();
  var bits: uint64 = 0;
  var encoding: uint32 = 0;
  if typ == "bool" {
    bits = 8u64;
    encoding = 2u32;
  }

  if typ == "int8" {
    bits = 8u64;
    encoding = 6u32;
  }

  if typ == "uint8" {
    bits = 8u64;
    encoding = 8u32;
  }

  if typ == "int16" {
    bits = 16u64;
    encoding = 5u32;
  }

  if typ == "uint16" {
    bits = 16u64;
    encoding = 7u32;
  }

  if typ == "int32" {
    bits = 32u64;
    encoding = 5u32;
  }

  if typ == "uint32" {
    bits = 32u64;
    encoding = 7u32;
  }

  if (typ == "int64") || (typ == "intptr") || (typ == "symbol") {
    bits = 64u64;
    encoding = 5u32;
  }

  if (typ == "uint64") || (typ == "uintptr") {
    bits = 64u64;
    encoding = 7u32;
  }

  if typ == "float32" {
    bits = 32u64;
    encoding = 4u32;
  }

  if typ == "float64" {
    bits = 64u64;
    encoding = 4u32;
  }

  if bits >(0u64) {
    return LLVMDIBuilderCreateBasicType(
      dib,
      (&mut name_buf[0]) as *const int8,
      typ.length as uintptr,
      bits,
      encoding,
      0u32
    );
  }

  if typ.StartsWith("*") || typ.StartsWith("ref ") {
    let pointee: *mut void = LLVMDIBuilderCreateUnspecifiedType(
      dib,
      (&mut name_buf[0]) as *const int8,
      typ.length as uintptr
    );

    return LLVMDIBuilderCreatePointerType(
      dib,
      pointee,
      64u64,
      64u32,
      0u32,
      (&mut name_buf[0]) as *const int8,
      typ.length as uintptr
    );
  }

  return LLVMDIBuilderCreateUnspecifiedType(dib,(&mut name_buf[0]) as *const int8, typ.length as uintptr);
}

/**
 * @brief Describe a stack slot as a local or argument in the current debug scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Declare(
  builder: Builder,
  slot: Value,
  name: string,
  typ: string,
  line: int32,
  arg_no: int32
) -> void {
  if !self.IsValid() || builder.handle == nil {
    return;
  }

  let dib: *mut void = self.builder;
  let sp: *mut void = self.function_scope;
  let block: *mut void = LLVMGetInsertBlock(builder.handle);
  let fn_value: *mut void = self.function;
  if (dib == nil)
    || (sp == nil)
    || (block == nil)
    || (LLVMGetBasicBlockParent(block) != fn_value) {
    return;
  }

  var ln: uint32 = 1;
  if line > 0 {
    ln = line as uint32;
  }

  var name_buf: owned <int8>[] = name.ToCStringBytes();
  let file: *mut void = self.file;
  let di_ty: *mut void = self.Type(typ);
  var variable: *mut void = 0 as *mut void;
  if arg_no > 0 {
    variable = LLVMDIBuilderCreateParameterVariable(
      dib,
      sp,
      (&mut name_buf[0]) as *const int8,
      name.length as uintptr,
      arg_no as uint32,
      file,
      ln,
      di_ty,
      1,
      0u32
    );
  } else {
    variable = LLVMDIBuilderCreateAutoVariable(
      dib,
      sp,
      (&mut name_buf[0]) as *const int8,
      name.length as uintptr,
      file,
      ln,
      di_ty,
      1,
      0u32,
      0u32
    );
  }

  let expr: *mut void = LLVMDIBuilderCreateExpression(dib, 0 as *mut void, 0up);
  let ctx: *mut void = self.context;
  let loc: *mut void = LLVMDIBuilderCreateDebugLocation(ctx, ln, 1u32, sp, 0 as *mut void);
  let _: *mut void = LLVMDIBuilderInsertDeclareRecordAtEnd(dib, slot.handle, variable, expr, loc, block);
}

/**
 * @brief Finalize pending DWARF metadata before disposing builder state.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Finalize() -> void {
  let dib: *mut void = self.builder;
  if dib != nil {
    LLVMDIBuilderFinalize(dib);
  }
}

/**
 * @brief Dispose the native DIBuilder and clear inline borrowed metadata; zero is a no-op.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Dispose() -> void {
  if self.builder != nil {
    LLVMDisposeDIBuilder(self.builder);
  }

  self.builder = 0 as *mut void;
  self.file = 0 as *mut void;
  self.unit = 0 as *mut void;
  self.signature = 0 as *mut void;
  self.function_scope = 0 as *mut void;
  self.context = 0 as *mut void;
  self.function = 0 as *mut void;
}

/** @brief Whether this handle retains native debug-builder state.
 * @returns False for allocation failure, default state or a disposed handle. */
pub method(DebugInfo) IsValid() -> bool {
  return self.builder != nil;
}

/**
 * @brief Transfer the live native debug builder and borrowed metadata handles.
 * @returns Sole owning value; the moved-from value contains only null handles.
 */
pub method(DebugInfo) operator move() -> DebugInfo {
  let builder: *mut void = self.builder;
  let file: *mut void = self.file;
  let unit: *mut void = self.unit;
  let signature: *mut void = self.signature;
  let function_scope: *mut void = self.function_scope;
  let context: *mut void = self.context;
  let function: *mut void = self.function;
  self.builder = 0 as *mut void;
  self.file = 0 as *mut void;
  self.unit = 0 as *mut void;
  self.signature = 0 as *mut void;
  self.function_scope = 0 as *mut void;
  self.context = 0 as *mut void;
  self.function = 0 as *mut void;

  return DebugInfo{
    builder: builder,
    file: file,
    unit: unit,
    signature: signature,
    function_scope: function_scope,
    context: context,
    function: function
  };
}

/**
 * @brief Copying would duplicate native DIBuilder disposal ownership.
 * @returns Deleted operation; transfer a live owner with move instead.
 */
pub method(DebugInfo) operator copy() -> DebugInfo = delete;
