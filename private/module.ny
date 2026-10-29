// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmModule;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "private/c_string.ny";
import "interface/module.ni";
import "interface/target.ni";

/**
 * @brief Open layout and Create/Dispose/Verify/AddFunction/EmitObject for `Module`.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

/**
 * @brief Create a module in `ctx` (`LLVMModuleCreateWithNameInContext`).
 * @param ctx Owning context.
 * @param name Module id (NUL-terminated C string crossing).
 * @returns Module handle owned by the caller; dispose it before its context is destroyed.
 */
pub static method(Module) Create(ctx: Context, name: string) -> Module {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMModuleCreateWithNameInContext((&mut cname[0]) as *const int8, ctx.handle);

  return Module{handle: handle};
}

/**
 * @brief `LLVMDisposeModule(self.handle)`. Does not `nyra_free`.
 */
pub method(Module) Dispose() -> void {
  LLVMDisposeModule(self.handle);
}

/** @brief Add one metadata node to a named module registry. */
pub method(Module) AddNamedMetadataOperand(name: string, value: Value) -> void {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  LLVMAddNamedMetadataOperand(self.handle,(&mut cname[0]) as *const int8, value.handle);
}

/**
 * @brief `LLVMSetTarget`.
 */
pub method(Module) SetTarget(triple: string) -> void {
  var ctriple: owned <int8>[] = LlvmCStringBuffer(triple);
  LLVMSetTarget(self.handle,(&mut ctriple[0]) as *const int8);
}

/**
 * @brief Read target triple (`LLVMGetTarget`); empty if unset.
 * @returns Target triple (`LLVMGetTarget`); empty if unset.
 */
pub method(Module) TargetTriple() -> string {
  let c: *const int8 = LLVMGetTarget(self.handle);
  if c == (0 as *const int8) {
    return "";
  }

  let n: int32 = string.StrLen(c as *const uint8) as int32;
  if n <= 0 {
    return "";
  }

  return copy(string.ViewFrom(c as *const int8, n));
}

/**
 * @brief `LLVMSetDataLayout`.
 */
pub method(Module) SetDataLayout(layout: string) -> void {
  var clayout: owned <int8>[] = LlvmCStringBuffer(layout);
  LLVMSetDataLayout(self.handle,(&mut clayout[0]) as *const int8);
}

/**
 * @brief Write LLVM IR to a file; dispose any message from LLVM.
 * @returns 0 = ok; nonzero = broken.
 */
pub method(Module) WriteIR(path: string) -> int32 {
  var out_msg_slot: intptr = 0 as intptr;
  let out_msg_ptr: *mut void = (&mut out_msg_slot) as *mut void;
  var cpath: owned <int8>[] = LlvmCStringBuffer(path);
  let st: int32 = LLVMPrintModuleToFile(self.handle,(&mut cpath[0]) as *const int8, out_msg_ptr);
  if out_msg_slot != (0 as intptr) {
    LLVMDisposeMessage(out_msg_slot as *mut int8);
  }

  return st;
}

/**
 * @brief Verify IR (`LLVMVerifyModule` + `LLVMPrintMessageAction`).
 * @returns `0` if valid; nonzero if broken. Disposes any LLVM message.
 */
pub method(Module) Verify() -> int32 {
  // LLVMPrintMessageAction == 1 — print the exact verifier finding and return.
  // Pass null OutMessage: a stack `char**` slot has been observed to corrupt the
  // LLVMBool return on very large modules (lexer mega-TU) while PrintModuleToFile
  // IR still verifies clean under the same libLLVM.
  let broken: int32 = LLVMVerifyModule(self.handle, 1,(0 as *mut void));

  return broken;
}

/**
 * @brief Add a function declaration/definition (`LLVMAddFunction`).
 * @param name Function name.
 * @param fn_ty Function type.
 * @returns Function `Value`.
 */
pub method(Module) AddFunction(name: string, fn_ty: Type) -> Value {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMAddFunction(self.handle,(&mut cname[0]) as *const int8, fn_ty.handle);

  return Value{handle: handle};
}

/**
 * @brief Lookup by name (`LLVMGetNamedFunction`); null handle if missing.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Module) NamedFunction(name: string) -> Value {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMGetNamedFunction(self.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Lookup global by name (`LLVMGetNamedGlobal`); null handle if missing.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Module) NamedGlobal(name: string) -> Value {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMGetNamedGlobal(self.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Add a global variable (`LLVMAddGlobal`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Module) AddGlobal(ty: Type, name: string) -> Value {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMAddGlobal(self.handle, ty.handle,(&mut cname[0]) as *const int8);

  return Value{handle: handle};
}

/**
 * @brief Convenience ObjectUnit emit: module triple if set, else host default.
 * @returns 0 on success.
 */
pub method(Module) EmitObject(path: string) -> int32 {
  var triple: string = self.TargetTriple();
  if triple.length == 0 {
    triple = DefaultTargetTriple();
  }

  return self.EmitObjectEx(path, triple, "generic", "", 2);
}

/**
 * @brief ObjectUnit emit for an explicit triple (+ CPU / features / opt).
 * @param code_model LLVMCodeModel (0 Default, 5 Medium = RISC-V medany).
 * @returns 0 on success.
 */
pub method(Module) EmitObjectEx(
  path: string,
  triple_in: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0, inline_ir: bool = false, relocation: int32 = 0, abi: string = ""}
) -> int32 {
  InitializeAll();
  var triple: string = copy(triple_in);
  if triple.length == 0 {
    triple = DefaultTargetTriple();
  }

  if triple.length == 0 {
    return 1;
  }

  self.SetTarget(triple);
  let target: Target = Target.FromTriple(triple);
  if target.handle == (0 as *mut void) {
    return 1;
  }

  let tm: TargetMachine = target.CreateTargetMachineEx(
    triple,
    cpu,
    features,
    opt_level,
    code_model: code_model,
    relocation: relocation,
    abi: abi
  );
  if tm.handle == (0 as *mut void) {
    return 1;
  }

  let td: TargetData = tm.CreateTargetData();
  if td.handle == (0 as *mut void) {
    tm.Dispose();

    return 1;
  }

  let layout_str: string = td.LayoutString();
  self.SetDataLayout(layout_str);
  td.Dispose();
  let mod_self: Module = Module{handle: self.handle};
  if inline_ir && (opt_level > 0) {
    if self.RunInlinePipeline(tm) != 0 {
      tm.Dispose();

      return 1;
    }
  }

  let status: int32 = tm.EmitToFile(mod_self, path);
  tm.Dispose();

  return status;
}

/** @brief Cost-model inlining honoring the module's explicit definition linkage. */
method(Module) RunInlinePipeline(tm: TargetMachine) -> int32 {
  let options: *mut void = LLVMCreatePassBuilderOptions();
  let pipeline: string = "cgscc(inline)";
  var cpasses: owned <int8>[] = LlvmCStringBuffer(pipeline);
  let err: *mut void = LLVMRunPasses(self.handle,(&mut cpasses[0]) as *const int8, tm.handle, options);
  LLVMDisposePassBuilderOptions(options);
  if err != (0 as *mut void) {
    let message: *mut int8 = LLVMGetErrorMessage(err);
    if message != (0 as *mut int8) {
      let length: int32 = string.StrLen(message as *const uint8) as int32;
      Console.Eprintln("[llvm] inline pipeline: ".Concat(string.ViewFrom(message as *const int8, length)));
      LLVMDisposeErrorMessage(message);
    }

    return 1;
  }

  return self.Verify();
}

/**
 * @brief LLVM's default IR optimization pipeline; 0..3, 10=Os, 11=Oz.
 * @returns Zero on success; a nonzero status on failure.
 */
pub method(Module) Optimize(
  triple: string,
  cpu: string,
  features: string,
  level: int32,
  {pipeline: string = "", relocation: int32 = 0, abi: string = ""}
) -> int32 {
  if level == 0 && pipeline.length == 0 {
    return 0;
  }

  var suffix: string = "";
  if level == 1 {
    suffix = "O1";
  } else if level == 2 {
    suffix = "O2";
  } else if level == 3 {
    suffix = "O3";
  } else if level == 10 {
    suffix = "Os";
  } else if level == 11 {
    suffix = "Oz";
  } else if level == 0 {
    suffix = "O0";
  } else {
    return 1;
  }

  let target: Target = Target.FromTriple(triple);
  if target.handle == (0 as *mut void) {
    return 1;
  }

  var machine_level: int32 = level;
  if machine_level > 3 {
    machine_level = 2;
  }

  let machine: TargetMachine = target.CreateTargetMachineEx(
    triple,
    cpu,
    features,
    machine_level,
    relocation: relocation,
    abi: abi
  );
  if machine.handle == (0 as *mut void) {
    return 1;
  }

  let options: *mut void = LLVMCreatePassBuilderOptions();
  if options == (0 as *mut void) {
    machine.Dispose();

    return 1;
  }

  // Required exports carry external/weak_odr linkage at module construction.
  // Leave linkonce_odr helpers discardable, as specified by LLVM semantics.
  var selected: string = pipeline;
  if selected.length == 0 {
    selected = "default<".Concat(suffix).Concat(">");
  }

  var passes: owned <int8>[] = LlvmCStringBuffer(selected);
  let error: *mut void = LLVMRunPasses(self.handle,(&mut passes[0]) as *const int8, machine.handle, options);
  LLVMDisposePassBuilderOptions(options);
  machine.Dispose();
  if error != (0 as *mut void) {
    let message: *mut int8 = LLVMGetErrorMessage(error);
    if message != (0 as *mut int8) {
      let length: int32 = string.StrLen(message as *const uint8) as int32;
      Console.Eprintln("[llvm] optimization: ".Concat(string.ViewFrom(message as *const int8, length)));
      LLVMDisposeErrorMessage(message);
    }

    return 1;
  }

  return self.Verify();
}
