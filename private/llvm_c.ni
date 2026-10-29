// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief LLVM-C `@extern("C")` decls for package `llvm` (v1 ObjectUnit slice).
 * @note Lives in `private/` only — not barrel-exported; not `source/stdlib/private/platform.ni`.
 * @note `nyra_llvm_initialize_all` is the only C shim (Target.h macros).
 * @see docs/design/compiler/nyra-llvm.md §1.2 · m_v0.6_p2 Record
 */

/**
 * @brief `LLVMContextRef LLVMContextCreate(void);`
 */
pub @extern("C") func LLVMContextCreate() -> *mut void;

/**
 * @brief `void LLVMContextDispose(LLVMContextRef C);`
 */
pub @extern("C") func LLVMContextDispose(c: *mut void) -> void;

/**
 * @brief `LLVMValueRef LLVMMDStringInContext(LLVMContextRef C, const char *Str, unsigned SLen);`
 */
pub @extern("C") func LLVMMDStringInContext(c: *mut void, str: *const int8, slen: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMMDNodeInContext(LLVMContextRef C, LLVMValueRef *Vals, unsigned
 *   Count);`
 */
pub @extern("C") func LLVMMDNodeInContext(c: *mut void, vals: *mut void, count: uint32) -> *mut void;

/**
 * @brief `void LLVMAddNamedMetadataOperand(LLVMModuleRef M, const char *Name, LLVMValueRef
 *   Val);`
 */
pub @extern("C") func LLVMAddNamedMetadataOperand(m: *mut void, name: *const int8, val: *mut void) -> void;

/**
 * @brief `void LLVMDisposeMessage(char *Message);`
 */
pub @extern("C") func LLVMDisposeMessage(message: *mut int8) -> void;

/**
 * @brief `LLVMModuleRef LLVMModuleCreateWithNameInContext(const char *ModuleID, LLVMContextRef
 *   C);`
 */
pub @extern("C") func LLVMModuleCreateWithNameInContext(module_id: *const int8, c: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeModule(LLVMModuleRef M);`
 */
pub @extern("C") func LLVMDisposeModule(m: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMPrintModuleToFile(LLVMModuleRef M, const char *Filename, char
 *   **ErrorMessage);`
 */
pub @extern("C") func LLVMPrintModuleToFile(
  m: *mut void,
  filename: *const int8,
  error_message: *mut void
) -> int32;

/**
 * @brief `void LLVMSetTarget(LLVMModuleRef M, const char *Triple);`
 */
pub @extern("C") func LLVMSetTarget(m: *mut void, triple: *const int8) -> void;

/**
 * @brief `const char *LLVMGetTarget(LLVMModuleRef M);` — owned by module; do not dispose.
 */
pub @extern("C") func LLVMGetTarget(m: *mut void) -> *const int8;

/**
 * @brief `void LLVMSetDataLayout(LLVMModuleRef M, const char *DataLayoutStr);`
 */
pub @extern("C") func LLVMSetDataLayout(m: *mut void, data_layout_str: *const int8) -> void;

/**
 * @brief `LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action, char
 *   **OutMessage);`
 * @note Action `2` = `LLVMReturnStatusAction`. `OutMessage` is `char**` as `*mut void` (NY5006).
 */
pub @extern("C") func LLVMVerifyModule(m: *mut void, action: int32, out_message: *mut void) -> int32;

// LLVM-C debug metadata entry points (llvm-c/DebugInfo.h).
pub @extern("C") func LLVMCreateDIBuilder(m: *mut void) -> *mut void;

pub @extern("C") func LLVMDIBuilderFinalize(builder: *mut void) -> void;

pub @extern("C") func LLVMDisposeDIBuilder(builder: *mut void) -> void;

pub @extern("C") func LLVMDIBuilderCreateFile(
  builder: *mut void,
  filename: *const int8,
  filename_len: uintptr,
  directory: *const int8,
  directory_len: uintptr
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateCompileUnit(
  builder: *mut void,
  lang: uint32,
  file: *mut void,
  producer: *const int8,
  producer_len: uintptr,
  is_optimized: int32,
  flags: *const int8,
  flags_len: uintptr,
  runtime_ver: uint32,
  split_name: *const int8,
  split_name_len: uintptr,
  kind: uint32,
  dwoid: uint32,
  split_debug_inlining: int32,
  debug_info_for_profiling: int32,
  sys_root: *const int8,
  sys_root_len: uintptr,
  sdk: *const int8,
  sdklen: uintptr
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateSubroutineType(
  builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  num_parameter_types: uint32,
  flags: uint32
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateFunction(
  builder: *mut void,
  scope_value: *mut void,
  name: *const int8,
  name_len: uintptr,
  linkage_name: *const int8,
  linkage_name_len: uintptr,
  file: *mut void,
  line_no: uint32,
  ty: *mut void,
  is_local_to_unit: int32,
  is_definition: int32,
  scope_line: uint32,
  flags: uint32,
  is_optimized: int32
) -> *mut void;

pub @extern("C") func LLVMSetSubprogram(func_value: *mut void, sp: *mut void) -> void;

pub @extern("C") func LLVMDIBuilderCreateDebugLocation(
  ctx: *mut void,
  line: uint32,
  column: uint32,
  scope_value: *mut void,
  inlined_at: *mut void
) -> *mut void;

pub @extern("C") func LLVMSetCurrentDebugLocation2(builder: *mut void, loc: *mut void) -> void;

pub @extern("C") func LLVMSetIsNewDbgInfoFormat(m: *mut void, use_new_format: int32) -> void;

pub @extern("C") func LLVMDIBuilderCreateBasicType(
  builder: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_in_bits: uint64,
  encoding: uint32,
  flags: uint32
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateUnspecifiedType(
  builder: *mut void,
  name: *const int8,
  name_len: uintptr
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreatePointerType(
  builder: *mut void,
  pointee_ty: *mut void,
  size_in_bits: uint64,
  align_in_bits: uint32,
  address_space: uint32,
  name: *const int8,
  name_len: uintptr
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateAutoVariable(
  builder: *mut void,
  scope_value: *mut void,
  name: *const int8,
  name_len: uintptr,
  file: *mut void,
  line_no: uint32,
  ty: *mut void,
  always_preserve: int32,
  flags: uint32,
  align_in_bits: uint32
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateParameterVariable(
  builder: *mut void,
  scope_value: *mut void,
  name: *const int8,
  name_len: uintptr,
  arg_no: uint32,
  file: *mut void,
  line_no: uint32,
  ty: *mut void,
  always_preserve: int32,
  flags: uint32
) -> *mut void;

pub @extern("C") func LLVMDIBuilderCreateExpression(
  builder: *mut void,
  addr: *mut void,
  length: uintptr
) -> *mut void;

pub @extern("C") func LLVMDIBuilderInsertDeclareRecordAtEnd(
  builder: *mut void,
  storage: *mut void,
  var_info: *mut void,
  expr: *mut void,
  debug_loc: *mut void,
  block: *mut void
) -> *mut void;

pub @extern("C") func LLVMGetBasicBlockParent(bb: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddFunction(LLVMModuleRef M, const char *Name, LLVMTypeRef
 *   FunctionTy);`
 */
pub @extern("C") func LLVMAddFunction(m: *mut void, name: *const int8, function_ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddGlobal(LLVMModuleRef M, LLVMTypeRef Ty, const char *Name);`
 */
pub @extern("C") func LLVMAddGlobal(m: *mut void, ty: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt1TypeInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMInt1TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt8TypeInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMInt8TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt32TypeInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMInt32TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt64TypeInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMInt64TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMVoidTypeInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMVoidTypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMPointerType(LLVMTypeRef ElementType, unsigned AddressSpace);`
 */
pub @extern("C") func LLVMPointerType(element_type: *mut void, address_space: uint32) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMFunctionType(LLVMTypeRef ReturnType, LLVMTypeRef *ParamTypes, unsigned
 *   ParamCount, LLVMBool IsVarArg);`
 */
pub @extern("C") func LLVMFunctionType(
  return_type: *mut void,
  param_types: *mut void,
  param_count: uint32,
  is_var_arg: int32
) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMStructTypeInContext(LLVMContextRef C, LLVMTypeRef *ElementTypes,
 *   unsigned ElementCount, LLVMBool Packed);`
 */
pub @extern("C") func LLVMStructTypeInContext(
  c: *mut void,
  element_types: *mut void,
  element_count: uint32,
  packed: int32
) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMStructCreateNamed(LLVMContextRef C, const char *Name);`
 */
pub @extern("C") func LLVMStructCreateNamed(c: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `void LLVMStructSetBody(LLVMTypeRef StructTy, LLVMTypeRef *ElementTypes, unsigned
 *   ElementCount, LLVMBool Packed);`
 */
pub @extern("C") func LLVMStructSetBody(
  struct_ty: *mut void,
  element_types: *mut void,
  element_count: uint32,
  packed: int32
) -> void;

/**
 * @brief `LLVMTypeRef LLVMArrayType(LLVMTypeRef ElementType, unsigned ElementCount);`
 */
pub @extern("C") func LLVMArrayType(element_type: *mut void, element_count: uint32) -> *mut void;

/** @brief `LLVMTypeRef LLVMArrayType2(LLVMTypeRef ElementType, uint64_t ElementCount);` */
pub @extern("C") func LLVMArrayType2(element_type: *mut void, element_count: uint64) -> *mut void;

pub @extern("C") func LLVMVectorType(element_type: *mut void, element_count: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetParam(LLVMValueRef Fn, unsigned Index);`
 */
pub @extern("C") func LLVMGetParam(fn: *mut void, index: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInt(LLVMTypeRef IntTy, unsigned long long N, LLVMBool
 *   SignExtend);`
 */
pub @extern("C") func LLVMConstInt(int_ty: *mut void, n: uint64, sign_extend: int32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPointerNull(LLVMTypeRef Ty);`
 */
pub @extern("C") func LLVMConstPointerNull(ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstStringInContext(LLVMContextRef C, const char *Str, unsigned
 *   Length, LLVMBool DontNullTerminate);`
 */
pub @extern("C") func LLVMConstStringInContext(
  c: *mut void,
  str: *const int8,
  length: uint32,
  dont_null_terminate: int32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstNamedStruct(LLVMTypeRef StructTy, LLVMValueRef *ConstantVals,
 *   unsigned Count);`
 */
pub @extern("C") func LLVMConstNamedStruct(
  struct_ty: *mut void,
  constant_vals: *mut void,
  count: uint32
) -> *mut void;

pub @extern("C") func LLVMConstStructInContext(
  c: *mut void,
  constant_vals: *mut void,
  count: uint32,
  packed: int32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInBoundsGEP2(LLVMTypeRef Ty, LLVMValueRef ConstantVal,
 *   LLVMValueRef *ConstantIndices, unsigned NumIndices);`
 */
pub @extern("C") func LLVMConstInBoundsGEP2(
  ty: *mut void,
  constant_val: *mut void,
  constant_indices: *mut void,
  num_indices: uint32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstArray(LLVMTypeRef ElementTy, LLVMValueRef *ConstantVals,
 *   unsigned Length);`
 */
pub @extern("C") func LLVMConstArray(
  element_ty: *mut void,
  constant_vals: *mut void,
  length: uint32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstBitCast(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
pub @extern("C") func LLVMConstBitCast(constant_val: *mut void, to_type: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstIntToPtr(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
pub @extern("C") func LLVMConstIntToPtr(constant_val: *mut void, to_type: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPtrToInt(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
pub @extern("C") func LLVMConstPtrToInt(constant_val: *mut void, to_type: *mut void) -> *mut void;

/**
 * @brief `void LLVMSetInitializer(LLVMValueRef GlobalVar, LLVMValueRef ConstantVal);`
 */
pub @extern("C") func LLVMSetInitializer(global_var: *mut void, constant_val: *mut void) -> void;

/**
 * @brief `void LLVMSetLinkage(LLVMValueRef Global, LLVMLinkage Linkage);`
 */
pub @extern("C") func LLVMSetLinkage(global: *mut void, linkage: int32) -> void;

/**
 * @brief `void LLVMSetGlobalConstant(LLVMValueRef GlobalVar, LLVMBool IsConstant);`
 */
pub @extern("C") func LLVMSetGlobalConstant(global_var: *mut void, is_constant: int32) -> void;

pub @extern("C") func LLVMSetThreadLocal(global_var: *mut void, is_thread_local: int32) -> void;

/**
 * @brief `LLVMBool LLVMIsNull(LLVMValueRef Val);`
 */
pub @extern("C") func LLVMIsNull(val: *mut void) -> int32;

/**
 * @brief `LLVMBool LLVMIsConstant(LLVMValueRef Val);`
 */
pub @extern("C") func LLVMIsConstant(val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMIsAConstantInt(LLVMValueRef Val);` null when `Val` is not a constant
 *   integer.
 */
pub @extern("C") func LLVMIsAConstantInt(val: *mut void) -> *mut void;

/**
 * @brief `unsigned long long LLVMConstIntGetZExtValue(LLVMValueRef ConstantVal);`
 */
pub @extern("C") func LLVMConstIntGetZExtValue(constant_val: *mut void) -> uint64;

/**
 * @brief `LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef C, LLVMValueRef Fn,
 *   const char *Name);`
 */
pub @extern("C") func LLVMAppendBasicBlockInContext(c: *mut void, fn: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMBuilderRef LLVMCreateBuilderInContext(LLVMContextRef C);`
 */
pub @extern("C") func LLVMCreateBuilderInContext(c: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeBuilder(LLVMBuilderRef Builder);`
 */
pub @extern("C") func LLVMDisposeBuilder(builder: *mut void) -> void;

/**
 * @brief `void LLVMPositionBuilderAtEnd(LLVMBuilderRef Builder, LLVMBasicBlockRef Block);`
 */
pub @extern("C") func LLVMPositionBuilderAtEnd(builder: *mut void, block: *mut void) -> void;

/**
 * @brief `void LLVMPositionBuilderBefore(LLVMBuilderRef Builder, LLVMValueRef Instr);`
 */
pub @extern("C") func LLVMPositionBuilderBefore(builder: *mut void, instr: *mut void) -> void;

/**
 * @brief `LLVMBasicBlockRef LLVMGetEntryBasicBlock(LLVMValueRef Fn);`
 */
pub @extern("C") func LLVMGetEntryBasicBlock(fn: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetFirstInstruction(LLVMBasicBlockRef BB);`
 */
pub @extern("C") func LLVMGetFirstInstruction(bb: *mut void) -> *mut void;

/**
 * @brief `void LLVMDeleteBasicBlock(LLVMBasicBlockRef BB);`
 */
pub @extern("C") func LLVMDeleteBasicBlock(bb: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMIsDeclaration(LLVMValueRef Val);` — 1 when function has no body.
 */
pub @extern("C") func LLVMIsDeclaration(val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMGetUndef(LLVMTypeRef Ty);`
 */
pub @extern("C") func LLVMGetUndef(ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAlloca(LLVMBuilderRef, LLVMTypeRef Ty, const char *Name);`
 */
pub @extern("C") func LLVMBuildAlloca(b: *mut void, ty: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildArrayAlloca(
  b: *mut void,
  ty: *mut void,
  val: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildLoad2(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef PointerVal,
 *   const char *Name);`
 */
pub @extern("C") func LLVMBuildLoad2(
  b: *mut void,
  ty: *mut void,
  pointer_val: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildStore(LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr);`
 */
pub @extern("C") func LLVMBuildStore(b: *mut void, val: *mut void, ptr: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const
 *   char *Name);`
 */
pub @extern("C") func LLVMBuildAdd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRet(LLVMBuilderRef, LLVMValueRef V);`
 */
pub @extern("C") func LLVMBuildRet(b: *mut void, v: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRetVoid(LLVMBuilderRef);`
 */
pub @extern("C") func LLVMBuildRetVoid(b: *mut void) -> *mut void;

pub @extern("C") func LLVMBuildUnreachable(b: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildBr(LLVMBuilderRef, LLVMBasicBlockRef Dest);`
 */
pub @extern("C") func LLVMBuildBr(b: *mut void, dest: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildCondBr(LLVMBuilderRef, LLVMValueRef If, LLVMBasicBlockRef Then,
 *   LLVMBasicBlockRef Else);`
 */
pub @extern("C") func LLVMBuildCondBr(
  b: *mut void,
  if_value: *mut void,
  then: *mut void,
  else_value: *mut void
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildCall2(LLVMBuilderRef, LLVMTypeRef, LLVMValueRef Fn, LLVMValueRef
 *   *Args, unsigned NumArgs, const char *Name);`
 */
pub @extern("C") func LLVMBuildCall2(
  b: *mut void,
  fn_ty: *mut void,
  fn: *mut void,
  args: *mut void,
  num_args: uint32,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildInBoundsGEP2(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef
 *   PointerVal, LLVMValueRef *Indices, unsigned NumIndices, const char *Name);`
 */
pub @extern("C") func LLVMBuildInBoundsGEP2(
  b: *mut void,
  ty: *mut void,
  pointer_val: *mut void,
  indices: *mut void,
  num_indices: uint32,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildInsertValue(LLVMBuilderRef, LLVMValueRef AggVal, LLVMValueRef
 *   EltVal, unsigned Index, const char *Name);`
 */
pub @extern("C") func LLVMBuildInsertValue(
  b: *mut void,
  agg_val: *mut void,
  elt_val: *mut void,
  index: uint32,
  name: *const int8
) -> *mut void;

/**
 * @brief Shim: expand five `LLVMInitializeAll*` macros (`nyra_llvm_initialize_all.c`).
 */
pub @extern("C") func nyra_llvm_initialize_all() -> void;

/**
 * @brief `char *LLVMGetDefaultTargetTriple(void);` — dispose with `LLVMDisposeMessage`.
 */
pub @extern("C") func LLVMGetDefaultTargetTriple() -> *mut int8;

/**
 * @brief `LLVMBool LLVMGetTargetFromTriple(const char *Triple, LLVMTargetRef *T, char
 *   **ErrorMessage);`
 * @note `T` and `ErrorMessage` are out-pointers as `*mut void` (NY5006).
 */
pub @extern("C") func LLVMGetTargetFromTriple(
  triple: *const int8,
  t: *mut void,
  error_message: *mut void
) -> int32;

/**
 * @brief `LLVMTargetMachineRef LLVMCreateTargetMachine(...);`
 * @note Level/Reloc/CodeModel are C enums passed as `int32`.
 */
pub @extern("C") func LLVMCreateTargetMachine(
  t: *mut void,
  triple: *const int8,
  cpu: *const int8,
  features: *const int8,
  level: int32,
  reloc: int32,
  code_model: int32
) -> *mut void;

/**
 * @brief `void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);`
 */
pub @extern("C") func LLVMDisposeTargetMachine(t: *mut void) -> void;

/** @brief Explicit target ABI is required for RISC-V soft/hard-float SDK separation. */
pub @extern("C") func LLVMCreateTargetMachineOptions() -> *mut void;

pub @extern("C") func LLVMDisposeTargetMachineOptions(options: *mut void);

pub @extern("C") func LLVMTargetMachineOptionsSetCPU(options: *mut void, cpu: *const int8);

pub @extern("C") func LLVMTargetMachineOptionsSetFeatures(options: *mut void, features: *const int8);

pub @extern("C") func LLVMTargetMachineOptionsSetABI(options: *mut void, abi: *const int8);

pub @extern("C") func LLVMTargetMachineOptionsSetCodeGenOptLevel(options: *mut void, level: int32);

pub @extern("C") func LLVMTargetMachineOptionsSetRelocMode(options: *mut void, relocation: int32);

pub @extern("C") func LLVMTargetMachineOptionsSetCodeModel(options: *mut void, model: int32);

pub @extern("C") func LLVMCreateTargetMachineWithOptions(
  target: *mut void,
  triple: *const int8,
  options: *mut void
) -> *mut void;

/**
 * @brief `LLVMTargetDataRef LLVMCreateTargetDataLayout(LLVMTargetMachineRef T);`
 */
pub @extern("C") func LLVMCreateTargetDataLayout(t: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeTargetData(LLVMTargetDataRef TD);`
 */
pub @extern("C") func LLVMDisposeTargetData(td: *mut void) -> void;

/** @brief `unsigned long long LLVMABISizeOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);` */
pub @extern("C") func LLVMABISizeOfType(td: *mut void, ty: *mut void) -> uint64;

/** @brief `unsigned LLVMABIAlignmentOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);` */
pub @extern("C") func LLVMABIAlignmentOfType(td: *mut void, ty: *mut void) -> uint32;

/**
 * @brief `unsigned long long LLVMOffsetOfElement(LLVMTargetDataRef TD, LLVMTypeRef StructTy,
 *   unsigned Element);`
 */
pub @extern("C") func LLVMOffsetOfElement(td: *mut void, struct_ty: *mut void, element: uint32) -> uint64;

/**
 * @brief `char *LLVMCopyStringRepOfTargetData(LLVMTargetDataRef TD);` — dispose with
 *   `LLVMDisposeMessage`.
 */
pub @extern("C") func LLVMCopyStringRepOfTargetData(td: *mut void) -> *mut int8;

/**
 * @brief `LLVMBool LLVMTargetMachineEmitToFile(..., LLVMCodeGenFileType codegen, char
 *   **ErrorMessage);`
 * @note `codegen` `1` = `LLVMObjectFile`. `ErrorMessage` as `*mut void`.
 */
pub @extern("C") func LLVMTargetMachineEmitToFile(
  t: *mut void,
  m: *mut void,
  filename: *const int8,
  codegen: int32,
  error_message: *mut void
) -> int32;

pub @extern("C") func LLVMInt16TypeInContext(c: *mut void) -> *mut void;

pub @extern("C") func LLVMIntTypeInContext(c: *mut void, num_bits: uint32) -> *mut void;

pub @extern("C") func LLVMFloatTypeInContext(c: *mut void) -> *mut void;

pub @extern("C") func LLVMDoubleTypeInContext(c: *mut void) -> *mut void;

pub @extern("C") func LLVMGetNamedFunction(m: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMGetNamedGlobal(m: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMTypeOf(val: *mut void) -> *mut void;

pub @extern("C") func LLVMGetTypeKind(ty: *mut void) -> int32;

pub @extern("C") func LLVMGetArrayLength2(array_ty: *mut void) -> uint64;

pub @extern("C") func LLVMGetIntTypeWidth(int_ty: *mut void) -> uint32;

pub @extern("C") func LLVMConstNull(ty: *mut void) -> *mut void;

pub @extern("C") func LLVMConstReal(real_ty: *mut void, n: float64) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstRealOfStringAndSize(LLVMTypeRef RealTy, const char *Str,
 *   unsigned SLen);`
 */
pub @extern("C") func LLVMConstRealOfStringAndSize(
  real_ty: *mut void,
  str: *const int8,
  slen: uint32
) -> *mut void;

pub @extern("C") func LLVMConstRealGetDouble(const_val: *mut void, loses_info: *mut int32) -> float64;

pub @extern("C") func LLVMCountParamTypes(function_ty: *mut void) -> uint32;

pub @extern("C") func LLVMGetParamTypes(function_ty: *mut void, dest: *mut void) -> void;

pub @extern("C") func LLVMCountStructElementTypes(struct_ty: *mut void) -> uint32;

pub @extern("C") func LLVMStructGetTypeAtIndex(struct_ty: *mut void, i: uint32) -> *mut void;

pub @extern("C") func LLVMGetInsertBlock(builder: *mut void) -> *mut void;

pub @extern("C") func LLVMBuildSub(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildMul(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildSDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildUDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildSRem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildURem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildAnd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildOr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildXor(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildShl(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildAShr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildLShr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildNeg(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildNot(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFAdd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFSub(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFMul(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFRem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildFNeg(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMBuildICmp(
  b: *mut void,
  pred: int32,
  lhs: *mut void,
  rhs: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildFCmp(
  b: *mut void,
  pred: int32,
  lhs: *mut void,
  rhs: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildTrunc(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildSExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildZExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildFPTrunc(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildFPExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildSIToFP(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildUIToFP(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildFPToSI(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildFPToUI(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildBitCast(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildPtrToInt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildIntToPtr(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildExtractValue(
  b: *mut void,
  agg_val: *mut void,
  index: uint32,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildSelect(
  b: *mut void,
  if_value: *mut void,
  then: *mut void,
  else_value: *mut void,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMBuildSwitch(
  b: *mut void,
  v: *mut void,
  else_value: *mut void,
  num_cases: uint32
) -> *mut void;

pub @extern("C") func LLVMAddCase(switch_value: *mut void, on_val: *mut void, dest: *mut void) -> void;

pub @extern("C") func LLVMBuildPhi(b: *mut void, ty: *mut void, name: *const int8) -> *mut void;

pub @extern("C") func LLVMAddIncoming(
  phi: *mut void,
  incoming_values: *mut void,
  incoming_blocks: *mut void,
  count: uint32
) -> void;

/**
 * @brief `LLVMBuildFence` — `ordering` is `LLVMAtomicOrdering` (SeqCst = 7).
 */
pub @extern("C") func LLVMBuildFence(
  b: *mut void,
  ordering: int32,
  single_thread: int32,
  name: *const int8
) -> *mut void;

pub @extern("C") func LLVMSetOrdering(memory_access_inst: *mut void, ordering: int32) -> void;

pub @extern("C") func LLVMSetWeak(cmp_xchg_inst: *mut void, is_weak: int32) -> void;

pub @extern("C") func LLVMBuildAtomicRMW(
  b: *mut void,
  op: int32,
  ptr: *mut void,
  val: *mut void,
  ordering: int32,
  single_thread: int32
) -> *mut void;

pub @extern("C") func LLVMBuildAtomicCmpXchg(
  b: *mut void,
  ptr: *mut void,
  cmp: *mut void,
  new_value: *mut void,
  success_ordering: int32,
  failure_ordering: int32,
  single_thread: int32
) -> *mut void;

/** @brief `LLVMGetInlineAsm` — inline assembly value (side-effect call target). */
pub @extern("C") func LLVMGetInlineAsm(
  ty: *mut void,
  asm_string: *const int8,
  asm_string_length: uint64,
  constraints: *const int8,
  constraints_length: uint64,
  has_side_effects: int32,
  is_align_stack: int32,
  dialect: int32,
  can_throw: int32
) -> *mut void;

pub @extern("C") func LLVMGetEnumAttributeKindForName(name: *const uint8, length: uintptr) -> uint32;

pub @extern("C") func LLVMCreateEnumAttribute(ctx: *mut void, kind: uint32, value: uint64) -> *mut void;

pub @extern("C") func LLVMAddAttributeAtIndex(fn: *mut void, index: uint32, attr: *mut void) -> void;

pub @extern("C") func LLVMAddCallSiteAttribute(call: *mut void, index: uint32, attr: *mut void) -> void;

pub @extern("C") func LLVMCreateTypeAttribute(ctx: *mut void, kind: uint32, ty: *mut void) -> *mut void;

pub @extern("C") func LLVMSetAlignment(instruction: *mut void, bytes: uint32) -> void;

pub @extern("C") func LLVMGetFirstFunction(mod: *mut void) -> *mut void;

pub @extern("C") func LLVMGetNextFunction(fn: *mut void) -> *mut void;

pub @extern("C") func LLVMGetLinkage(fn: *mut void) -> int32;

pub @extern("C") func LLVMCreatePassBuilderOptions() -> *mut void;

pub @extern("C") func LLVMDisposePassBuilderOptions(options: *mut void) -> void;

pub @extern("C") func LLVMRunPasses(
  mod: *mut void,
  passes: *const int8,
  tm: *mut void,
  options: *mut void
) -> *mut void;

pub @extern("C") func LLVMGetErrorMessage(err: *mut void) -> *mut int8;

pub @extern("C") func LLVMDisposeErrorMessage(message: *mut int8) -> void;

pub @extern("C") func LLVMGetTypeContext(ty: *mut void) -> *mut void;

pub @extern("C") func LLVMGetBasicBlockTerminator(block: *mut void) -> *mut void;

pub @extern("C") func LLVMGetGlobalContext() -> *mut void;

pub @extern("C") func LLVMGetValueName2(value: *mut void, length: *mut uintptr) -> *const int8;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_add_debug_module_flags(module_ref: *mut void) -> void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_prepare_coff_comdats(module_ref: *mut void) -> void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_basic_type(
  di_builder: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64,
  encoding: uint32
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_pointer_type(
  di_builder: *mut void,
  base_type: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_function_pointer_type(
  di_builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_array_type(
  di_builder: *mut void,
  element_type: *mut void,
  size_bits: uint64,
  align_bits: uint32,
  length: int64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_composite_begin(
  di_builder: *mut void,
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  is_union: uint32,
  pending: *mut *mut void
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_composite_member(
  di_builder: *mut void,
  composite: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  line: uint32,
  size_bits: uint64,
  align_bits: uint32,
  offset_bits: uint64,
  member_type: *mut void,
  pending: *mut *mut void
) -> uint32;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_composite_end(
  di_builder: *mut void,
  composite: *mut void,
  pending: *mut *mut void
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_composite_discard_pending(pending: *mut *mut void) -> void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_debug_declare(
  builder: *mut void,
  di_builder: *mut void,
  storage: *mut void,
  scope_ref: *mut void,
  file: *mut void,
  name: *const int8,
  name_len: uintptr,
  debug_type: *mut void,
  line: uint32,
  arg_no: uint32
) -> void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func LLVMBuildMemMove(
  builder: *mut void,
  destination: *mut void,
  destination_align: uint32,
  source: *mut void,
  source_align: uint32,
  size: *mut void
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func LLVMBuildMemSet(
  builder: *mut void,
  destination: *mut void,
  byte_value: *mut void,
  size: *mut void,
  alignment: uint32
) -> *mut void;
