// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmDebugInfo;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "private/c_string.ny";
import "interface/debug_info.ni";

/** @brief LLVM-C DIBuilder support for DWARF line tables and function scopes. */

// The native debug state is a fixed slot array; a zero state must remain a no-op at every debug entry.
func debug_load(state: intptr, index: int32) -> *mut void {
  if state == (0 as intptr) {
    return 0 as *mut void;
  }

  unsafe {
    let slot: *mut intptr = (state + ((index as intptr) * (8 as intptr))) as *mut intptr;

    return (*slot) as *mut void;
  }
}

// Only access the native state after the zero guard; slot ownership remains with DebugInfoDispose.
func debug_store(state: intptr, index: int32, value: *mut void) -> void {
  if state == (0 as intptr) {
    return;
  }

  unsafe {
    let slot: *mut intptr = (state + ((index as intptr) * (8 as intptr))) as *mut intptr;
    *slot = value as intptr;
  }
}

/**
 * @brief Create native DWARF builder state for a module and source path.
 * @returns Owned opaque state, or zero if the state allocation fails.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoCreate(ctx: Context, mod: Module, source_path: string, optimized: bool) -> intptr {
  let state: intptr = _nyra_malloc(56 as int64, 8 as int64) as intptr;
  if state == (0 as intptr) {
    return 0 as intptr;
  }

  var path_buf: owned <int8>[] = LlvmCStringBuffer(source_path);
  var producer: string = copy("Nyra compiler");
  var producer_buf: owned <int8>[] = LlvmCStringBuffer(producer);
  var empty: string = "";
  var empty_buf: owned <int8>[] = LlvmCStringBuffer(empty);
  LLVMSetIsNewDbgInfoFormat(mod.handle, 1);
  let dib: *mut void = LLVMCreateDIBuilder(mod.handle);
  let file: *mut void = LLVMDIBuilderCreateFile(
    dib,
    (&mut path_buf[0]) as *const int8,
    source_path.length as uintptr,
    (&mut empty_buf[0]) as *const int8,
    0 as uintptr
  );
  var opt: int32 = 0;
  if optimized {
    opt = 1;
  }

  // LLVMDWARFSourceLanguageC99 == 11 (LLVM enum, not DW_LANG_C99).
  let cu: *mut void = LLVMDIBuilderCreateCompileUnit(
    dib,
    11 as uint32,
    file,
    (&mut producer_buf[0]) as *const int8,
    producer.length as uintptr,
    opt,
    (&mut empty_buf[0]) as *const int8,
    0 as uintptr,
    0 as uint32,
    (&mut empty_buf[0]) as *const int8,
    0 as uintptr,
    1 as uint32,
    0 as uint32,
    1,
    0,
    (&mut empty_buf[0]) as *const int8,
    0 as uintptr,
    (&mut empty_buf[0]) as *const int8,
    0 as uintptr
  );
  let subty: *mut void = LLVMDIBuilderCreateSubroutineType(
    dib,
    file,
    0 as *mut void,
    0 as uint32,
    0 as uint32
  );
  debug_store(state, 0, dib);
  debug_store(state, 1, file);
  debug_store(state, 2, cu);
  debug_store(state, 3, subty);
  debug_store(state, 4, 0 as *mut void);
  debug_store(state, 5, ctx.handle);
  debug_store(state, 6, 0 as *mut void);

  return state;
}

/**
 * @brief Attach a source-level function scope and retain it as the current debug scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoAttachFunction(
  state: intptr,
  fn_value: Value,
  name: string,
  line: int32,
  optimized: bool
) -> void {
  let dib: *mut void = debug_load(state, 0);
  if dib == (0 as *mut void) {
    return;
  }

  var name_buf: owned <int8>[] = LlvmCStringBuffer(name);
  var opt: int32 = 0;
  if optimized {
    opt = 1;
  }

  var ln: uint32 = 1;
  if line > 0 {
    ln = line as uint32;
  }

  let file: *mut void = debug_load(state, 1);
  let subty: *mut void = debug_load(state, 3);
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
    0 as uint32,
    opt
  );
  LLVMSetSubprogram(fn_value.handle, sp);
  debug_store(state, 4, sp);
  debug_store(state, 6, fn_value.handle);
}

/**
 * @brief Set builder location within the current debug function scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoSetLocation(state: intptr, builder: Builder, line: int32) -> void {
  let dib: *mut void = debug_load(state, 0);
  let sp: *mut void = debug_load(state, 4);
  let block: *mut void = LLVMGetInsertBlock(builder.handle);
  let fn_value: *mut void = debug_load(state, 6);
  if (dib == (0 as *mut void))
    || (sp == (0 as *mut void))
    || (block == (0 as *mut void))
    || (LLVMGetBasicBlockParent(block) != fn_value)
    || (line <= 0) {
    return;
  }

  let ctx: *mut void = debug_load(state, 5);
  let loc: *mut void = LLVMDIBuilderCreateDebugLocation(ctx, line as uint32, 1 as uint32, sp, 0 as *mut void);
  LLVMSetCurrentDebugLocation2(builder.handle, loc);
}

// Map source spellings to the limited debug type vocabulary without changing the lowered LLVM value type.
func debug_type(state: intptr, typ: string) -> *mut void {
  let dib: *mut void = debug_load(state, 0);
  var name_buf: owned <int8>[] = LlvmCStringBuffer(typ);
  var bits: uint64 = 0 as uint64;
  var encoding: uint32 = 0 as uint32;
  if typ == "bool" {
    bits = 8 as uint64;
    encoding = 2 as uint32;
  }

  if typ == "int8" {
    bits = 8 as uint64;
    encoding = 6 as uint32;
  }

  if typ == "uint8" {
    bits = 8 as uint64;
    encoding = 8 as uint32;
  }

  if typ == "int16" {
    bits = 16 as uint64;
    encoding = 5 as uint32;
  }

  if typ == "uint16" {
    bits = 16 as uint64;
    encoding = 7 as uint32;
  }

  if typ == "int32" {
    bits = 32 as uint64;
    encoding = 5 as uint32;
  }

  if typ == "uint32" {
    bits = 32 as uint64;
    encoding = 7 as uint32;
  }

  if (typ == "int64") || (typ == "intptr") || (typ == "symbol") {
    bits = 64 as uint64;
    encoding = 5 as uint32;
  }

  if (typ == "uint64") || (typ == "uintptr") {
    bits = 64 as uint64;
    encoding = 7 as uint32;
  }

  if typ == "float32" {
    bits = 32 as uint64;
    encoding = 4 as uint32;
  }

  if typ == "float64" {
    bits = 64 as uint64;
    encoding = 4 as uint32;
  }

  if bits >(0 as uint64) {
    return LLVMDIBuilderCreateBasicType(
      dib,
      (&mut name_buf[0]) as *const int8,
      typ.length as uintptr,
      bits,
      encoding,
      0 as uint32
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
      64 as uint64,
      64 as uint32,
      0 as uint32,
      (&mut name_buf[0]) as *const int8,
      typ.length as uintptr
    );
  }

  return LLVMDIBuilderCreateUnspecifiedType(dib,(&mut name_buf[0]) as *const int8, typ.length as uintptr);
}

/**
 * @brief Describe a stack slot as a local or argument in the current debug scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoDeclare(
  state: intptr,
  builder: Builder,
  slot: Value,
  name: string,
  typ: string,
  line: int32,
  arg_no: int32
) -> void {
  let dib: *mut void = debug_load(state, 0);
  let sp: *mut void = debug_load(state, 4);
  let block: *mut void = LLVMGetInsertBlock(builder.handle);
  let fn_value: *mut void = debug_load(state, 6);
  if (dib == (0 as *mut void))
    || (sp == (0 as *mut void))
    || (block == (0 as *mut void))
    || (LLVMGetBasicBlockParent(block) != fn_value) {
    return;
  }

  var ln: uint32 = 1;
  if line > 0 {
    ln = line as uint32;
  }

  var name_buf: owned <int8>[] = LlvmCStringBuffer(name);
  let file: *mut void = debug_load(state, 1);
  let di_ty: *mut void = debug_type(state, typ);
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
      0 as uint32
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
      0 as uint32,
      0 as uint32
    );
  }

  let expr: *mut void = LLVMDIBuilderCreateExpression(dib, 0 as *mut void, 0 as uintptr);
  let ctx: *mut void = debug_load(state, 5);
  let loc: *mut void = LLVMDIBuilderCreateDebugLocation(ctx, ln, 1 as uint32, sp, 0 as *mut void);
  let _: *mut void = LLVMDIBuilderInsertDeclareRecordAtEnd(dib, slot.handle, variable, expr, loc, block);
}

/**
 * @brief Finalize pending DWARF metadata before disposing builder state.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoFinalize(state: intptr) -> void {
  let dib: *mut void = debug_load(state, 0);
  if dib != (0 as *mut void) {
    LLVMDIBuilderFinalize(dib);
  }
}

/**
 * @brief Dispose the native DIBuilder and free its state; zero is a no-op.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoDispose(state: intptr) -> void {
  if state == (0 as intptr) {
    return;
  }

  let dib: *mut void = debug_load(state, 0);
  if dib != (0 as *mut void) {
    LLVMDisposeDIBuilder(dib);
  }

  _nyra_free(state as *mut int8);
}
