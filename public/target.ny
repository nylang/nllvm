/**
 * @brief Open layouts and Target / TargetMachine / TargetData / InitializeAll.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetRef` as `*mut void`.
 */
pub struct Target {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetMachineRef` as `*mut void`.
 */
pub struct TargetMachine {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetDataRef` as `*mut void`.
 */
pub struct TargetData {
  handle: *mut void;
}

/**
 * @brief Call `nyra_llvm_initialize_all` (five LLVMInitializeAll* macros).
 */
pub func InitializeAll() -> void {
  nyra_llvm_initialize_all();
}

/**
 * @brief Copy `LLVMGetDefaultTargetTriple` into a Nyra string; dispose C buffer.
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
 * @brief `LLVMGetTargetFromTriple`; null handle on failure (message disposed).
 */
pub static method(Target) FromTriple(triple: string) -> Target {
  var t_slot: intptr = 0 as intptr;
  var err_slot: intptr = 0 as intptr;
  let t_ptr: *mut void = (&mut t_slot) as *mut void;
  let err_ptr: *mut void = (&mut err_slot) as *mut void;
  var ctriple: owned <int8>[] = llvm_cstr_buf(triple);
  let status: int32 = LLVMGetTargetFromTriple((&mut ctriple[0]) as *const int8, t_ptr, err_ptr);
  if err_slot != (0 as intptr) {
    LLVMDisposeMessage(err_slot as *mut int8);
  }
  if status != 0 {
    return Target{ handle: 0 as *mut void };
  }
  return Target{ handle: t_slot as *mut void };
}

/**
 * @brief `LLVMCreateTargetMachine` with CPU `"generic"`, empty features, defaults.
 * @note Level=`LLVMCodeGenLevelDefault`(2), Reloc=`LLVMRelocDefault`(0),
 *       CodeModel=`LLVMCodeModelDefault`(0).
 */
pub method(Target) CreateTargetMachine(triple: string) -> TargetMachine {
  return self.CreateTargetMachineEx(triple, "generic", "", 2);
}

/**
 * @brief `LLVMCreateTargetMachine` with CPU / features / opt level.
 * @param opt_level LLVMCodeGenOptLevel: 0 None, 1 Less, 2 Default, 3 Aggressive.
 * @param code_model LLVMCodeModel: 0 Default, 1 JITDefault, 2 Tiny, 3 Small,
 *        4 Kernel, 5 Medium, 6 Large. RISC-V maps Small→medlow, Medium→medany,
 *        Large→medlarge; bare-metal images above 2 GiB need Medium.
 */
pub method(Target) CreateTargetMachineEx(
  triple: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0,relocation:int32=0}
) -> TargetMachine {
  if relocation<0||relocation>6{return TargetMachine{handle:0 as *mut void};}
  var ctriple: owned <int8>[] = llvm_cstr_buf(triple);
  var cpu_s: string = copy(cpu);
  if cpu_s.length <= 0 {
    cpu_s = copy("generic");
  }
  var ccpu: owned <int8>[] = llvm_cstr_buf(cpu_s);
  var cfeat: owned <int8>[] = llvm_cstr_buf(features);
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
  let handle: *mut void = LLVMCreateTargetMachine(
    self.handle,
    (&mut ctriple[0]) as *const int8,
    (&mut ccpu[0]) as *const int8,
    (&mut cfeat[0]) as *const int8,
    level,
    relocation,
    cm
  );
  return TargetMachine{ handle: handle };
}

/**
 * @brief `LLVMDisposeTargetMachine(self.handle)`.
 */
pub method(TargetMachine) Dispose() -> void {
  LLVMDisposeTargetMachine(self.handle);
}

/**
 * @brief `LLVMCreateTargetDataLayout`.
 */
pub method(TargetMachine) CreateTargetData() -> TargetData {
  let handle: *mut void = LLVMCreateTargetDataLayout(self.handle);
  return TargetData{ handle: handle };
}

/**
 * @brief `LLVMTargetMachineEmitToFile` with `LLVMObjectFile` (1).
 * @returns 0 on success.
 */
pub method(TargetMachine) EmitToFile(mod: Module, path: string) -> int32 {
  var err_slot: intptr = 0 as intptr;
  let err_ptr: *mut void = (&mut err_slot) as *mut void;
  var cpath: owned <int8>[] = llvm_cstr_buf(path);
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
 * @brief Copy `LLVMCopyStringRepOfTargetData`; dispose C buffer.
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

pub method(TargetData) ABISizeOfHandle(type_handle: *mut void) -> uint64 {
  return LLVMABISizeOfType(self.handle, type_handle);
}

pub method(TargetData) ABIAlignmentOfHandle(type_handle: *mut void) -> uint32 {
  return LLVMABIAlignmentOfType(self.handle, type_handle);
}

pub method(TargetData) OffsetOfElementHandle(type_handle: *mut void, index: uint32) -> uint64 {
  return LLVMOffsetOfElement(self.handle, type_handle, index);
}
