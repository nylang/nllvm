// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmTarget;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "private/c_string.ny";
import "interface/target.ni";

/**
 * @brief Open layouts and Target / TargetMachine / TargetData / InitializeAll.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

/**
 * @brief Call `nyra_llvm_initialize_all` (five LLVMInitializeAll* macros).
 */
pub func InitializeAll() -> void {
  nyra_llvm_initialize_all();
}

/**
 * @brief Host default triple (`LLVMGetDefaultTargetTriple`); copies then disposes C buffer.
 * @returns Host default triple (`LLVMGetDefaultTargetTriple`); copies then disposes C buffer.
 */
pub func DefaultTargetTriple() -> string {
  let c: *mut int8 = LLVMGetDefaultTargetTriple();
  if c == (0 as *mut int8) {
    return "";
  }

  let n: int32 = string.StrLen(c as *const uint8) as int32;
  let copied: string = copy(string.ViewFrom(c as *const int8, n));
  LLVMDisposeMessage(c);

  return copied;
}

/**
 * @brief Look up a target (`LLVMGetTargetFromTriple`). Null handle on failure.
 * @returns Registry-owned target handle, or a null handle if lookup fails.
 */
pub static method(Target) FromTriple(triple: string) -> Target {
  var t_slot: intptr = 0 as intptr;
  var err_slot: intptr = 0 as intptr;
  let t_ptr: *mut void = (&mut t_slot) as *mut void;
  let err_ptr: *mut void = (&mut err_slot) as *mut void;
  var ctriple: owned <int8>[] = LlvmCStringBuffer(triple);
  let status: int32 = LLVMGetTargetFromTriple((&mut ctriple[0]) as *const int8, t_ptr, err_ptr);
  if err_slot != (0 as intptr) {
    LLVMDisposeMessage(err_slot as *mut int8);
  }

  if status != 0 {
    return Target{handle: 0 as *mut void};
  }

  return Target{handle: t_slot as *mut void};
}

/**
 * @brief Create a TargetMachine for `triple` (CPU `"generic"`, empty features, defaults).
 * @returns Target-machine handle to release with Dispose.
 */
pub method(Target) CreateTargetMachine(triple: string) -> TargetMachine {
  return self.CreateTargetMachineEx(triple, "generic", "", 2);
}

/**
 * @brief Create a TargetMachine with CPU / features / opt level / code model.
 * @param opt_level LLVMCodeGenOptLevel: 0 None, 1 Less, 2 Default, 3 Aggressive.
 * @param code_model LLVMCodeModel: 0 Default, 5 Medium. RISC-V maps Small→medlow, Medium→medany,
 *   Large→medlarge — bare-metal images above 2 GiB need Medium.
 * @returns Target-machine handle to release with Dispose.
 */
pub method(Target) CreateTargetMachineEx(
  triple: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0, relocation: int32 = 0, abi: string = ""}
) -> TargetMachine {
  if relocation<0 || relocation>6 {
    return TargetMachine{handle: 0 as *mut void};
  }

  var ctriple: owned <int8>[] = LlvmCStringBuffer(triple);
  var cpu_s: string = copy(cpu);
  if cpu_s.length <= 0 {
    cpu_s = copy("generic");
  }

  var ccpu: owned <int8>[] = LlvmCStringBuffer(cpu_s);
  var cfeat: owned <int8>[] = LlvmCStringBuffer(features);
  var level: int32 = opt_level;
  if level < 0 {
    level = 0;
  }

  if level > 3 {
    level = 3;
  }

  var cm: int32 = code_model;
  if cm < 0 {
    cm = 0;
  }

  if cm > 6 {
    cm = 0;
  }

  if abi.length > 0 {
    let options: *mut void = LLVMCreateTargetMachineOptions();
    if options == (0 as *mut void) {
      return TargetMachine{handle: 0 as *mut void};
    }

    var cabi: owned <int8>[] = LlvmCStringBuffer(abi);
    LLVMTargetMachineOptionsSetCPU(options,(&mut ccpu[0]) as *const int8);
    LLVMTargetMachineOptionsSetFeatures(options,(&mut cfeat[0]) as *const int8);
    LLVMTargetMachineOptionsSetABI(options,(&mut cabi[0]) as *const int8);
    LLVMTargetMachineOptionsSetCodeGenOptLevel(options, level);
    LLVMTargetMachineOptionsSetRelocMode(options, relocation);
    LLVMTargetMachineOptionsSetCodeModel(options, cm);
    let configured: *mut void = LLVMCreateTargetMachineWithOptions(
      self.handle,
      (&mut ctriple[0]) as *const int8,
      options
    );
    LLVMDisposeTargetMachineOptions(options);

    return TargetMachine{handle: configured};
  }

  let handle: *mut void = LLVMCreateTargetMachine(
    self.handle,
    (&mut ctriple[0]) as *const int8,
    (&mut ccpu[0]) as *const int8,
    (&mut cfeat[0]) as *const int8,
    level,
    relocation,
    cm
  );

  return TargetMachine{handle: handle};
}

/**
 * @brief `LLVMDisposeTargetMachine(self.handle)`.
 */
pub method(TargetMachine) Dispose() -> void {
  LLVMDisposeTargetMachine(self.handle);
}

/**
 * @brief `LLVMCreateTargetDataLayout`; caller must `TargetData.Dispose`.
 * @returns Target-layout handle to release with Dispose.
 */
pub method(TargetMachine) CreateTargetData() -> TargetData {
  let handle: *mut void = LLVMCreateTargetDataLayout(self.handle);

  return TargetData{handle: handle};
}

/**
 * @brief `LLVMTargetMachineEmitToFile` with `LLVMObjectFile` (1).
 * @returns 0 on success.
 */
pub method(TargetMachine) EmitToFile(mod: Module, path: string) -> int32 {
  var err_slot: intptr = 0 as intptr;
  let err_ptr: *mut void = (&mut err_slot) as *mut void;
  var cpath: owned <int8>[] = LlvmCStringBuffer(path);
  let fail: int32 = LLVMTargetMachineEmitToFile(
    self.handle,
    mod.handle,
    (&mut cpath[0]) as *const int8,
    1,
    err_ptr
  );
  if err_slot != (0 as intptr) {
    LLVMDisposeMessage(err_slot as *mut int8);
  }

  return fail;
}

/**
 * @brief `LLVMDisposeTargetData(self.handle)`.
 */
pub method(TargetData) Dispose() -> void {
  LLVMDisposeTargetData(self.handle);
}

/**
 * @brief Data-layout string (`LLVMCopyStringRepOfTargetData`); owns the Nyra copy.
 * @returns Data-layout string (`LLVMCopyStringRepOfTargetData`); owns the Nyra copy.
 */
pub method(TargetData) LayoutString() -> string {
  let c: *mut int8 = LLVMCopyStringRepOfTargetData(self.handle);
  if c == (0 as *mut int8) {
    return "";
  }

  let n: int32 = string.StrLen(c as *const uint8) as int32;
  let copied: string = copy(string.ViewFrom(c as *const int8, n));
  LLVMDisposeMessage(c);

  return copied;
}

/**
 * @brief Query the target ABI allocation size of a borrowed LLVM type handle.
 * @returns Allocation size in bytes under this target data layout.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) ABISizeOfHandle(type_handle: *mut void) -> uint64 {
  return LLVMABISizeOfType(self.handle, type_handle);
}

/**
 * @brief Query the target ABI alignment of a borrowed LLVM type handle.
 * @returns Required ABI alignment in bytes.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) ABIAlignmentOfHandle(type_handle: *mut void) -> uint32 {
  return LLVMABIAlignmentOfType(self.handle, type_handle);
}

/**
 * @brief Query a struct element offset under this target data layout.
 * @returns Byte offset of the zero-based element index.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) OffsetOfElementHandle(type_handle: *mut void, index: uint32) -> uint64 {
  return LLVMOffsetOfElement(self.handle, type_handle, index);
}
