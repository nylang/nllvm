// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief LLVM-C `@extern("C")` decls for package `llvm` (v1 ObjectUnit slice).
 * @note Lives in `private/` only — not barrel-exported; not `source/stdlib/private/platform.ni`.
 * @note Internal shims adapt target initialization and native compiler debug metadata.
 * @see docs/design/compiler/nyra-llvm.md §1.2 · m_v0.6_p2 Record
 */

/**
 * @brief `LLVMContextRef LLVMContextCreate(void);`
 * @returns New context; release it with LLVMContextDispose after its dependent objects.
 */
pub @extern("C") func LLVMContextCreate() -> *mut void;

/**
 * @brief `void LLVMContextDispose(LLVMContextRef C);`
 */
pub @extern("C") func LLVMContextDispose(c: *mut void) -> void;

/**
 * @brief `LLVMValueRef LLVMMDStringInContext(LLVMContextRef C, const char *Str, unsigned SLen);`
 * @returns Metadata string as an LLVM value reference, owned by the supplied context.
 */
pub @extern("C") func LLVMMDStringInContext(c: *mut void, str: *const int8, slen: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMMDNodeInContext(LLVMContextRef C, LLVMValueRef *Vals, unsigned
 *   Count);`
 * @returns Metadata node as an LLVM value reference, owned by the supplied context.
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
 * @returns New module borrowing the context; release with LLVMDisposeModule.
 */
pub @extern("C") func LLVMModuleCreateWithNameInContext(module_id: *const int8, c: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeModule(LLVMModuleRef M);`
 */
pub @extern("C") func LLVMDisposeModule(m: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMPrintModuleToFile(LLVMModuleRef M, const char *Filename, char
 *   **ErrorMessage);`
 * @returns Zero on successful write; nonzero on failure with an owned error message.
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
 * @returns Borrowed target-triple text held by the module; do not dispose the pointer.
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
 * @returns Zero for valid IR; nonzero for invalid IR. Dispose any returned message with LLVMDisposeMessage.
 */
pub @extern("C") func LLVMVerifyModule(m: *mut void, action: int32, out_message: *mut void) -> int32;

// LLVM-C debug metadata entry points (llvm-c/DebugInfo.h).
/**
 * @brief Private LLVM-C `LLVMCreateDIBuilder` binding with borrowed input handles/storage.
 * @returns New DIBuilder borrowing the module; finalize and release with LLVMDisposeDIBuilder.
 */
pub @extern("C") func LLVMCreateDIBuilder(m: *mut void) -> *mut void;

/**
 * @brief Finalize metadata before disposing the native DIBuilder.
 */
pub @extern("C") func LLVMDIBuilderFinalize(builder: *mut void) -> void;

/**
 * @brief Dispose the native DIBuilder after finalization; the module remains caller-owned.
 */
pub @extern("C") func LLVMDisposeDIBuilder(builder: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateFile` binding with borrowed input handles/storage.
 * @returns File metadata owned by the LLVM context; filename/directory spans are borrowed for the call.
 */
pub @extern("C") func LLVMDIBuilderCreateFile(
  builder: *mut void,
  filename: *const int8,
  filename_len: uintptr,
  directory: *const int8,
  directory_len: uintptr
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateCompileUnit` binding with borrowed input handles/storage.
 * @returns Compile-unit metadata owned by the LLVM context.
 */
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

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateSubroutineType` binding with borrowed input handles/storage.
 * @returns Subroutine-type metadata owned by the LLVM context; the input metadata array is borrowed.
 */
pub @extern("C") func LLVMDIBuilderCreateSubroutineType(
  builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  num_parameter_types: uint32,
  flags: uint32
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateFunction` binding with borrowed input handles/storage.
 * @returns Subprogram metadata owned by the LLVM context.
 */
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

/**
 * @brief Attach subprogram metadata to a function value.
 */
pub @extern("C") func LLVMSetSubprogram(func_value: *mut void, sp: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateDebugLocation` binding with borrowed input handles/storage.
 * @returns Location metadata owned by the supplied LLVM context.
 */
pub @extern("C") func LLVMDIBuilderCreateDebugLocation(
  ctx: *mut void,
  line: uint32,
  column: uint32,
  scope_value: *mut void,
  inlined_at: *mut void
) -> *mut void;

/**
 * @brief Set or clear the instruction builder current debug location.
 */
pub @extern("C") func LLVMSetCurrentDebugLocation2(builder: *mut void, loc: *mut void) -> void;

/**
 * @brief Select LLVM debug-record representation for a module.
 */
pub @extern("C") func LLVMSetIsNewDbgInfoFormat(m: *mut void, use_new_format: int32) -> void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateBasicType` binding with borrowed input handles/storage.
 * @returns Basic-type metadata owned by the LLVM context.
 */
pub @extern("C") func LLVMDIBuilderCreateBasicType(
  builder: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_in_bits: uint64,
  encoding: uint32,
  flags: uint32
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateUnspecifiedType` binding with borrowed input handles/storage.
 * @returns Unspecified-type metadata owned by the LLVM context.
 */
pub @extern("C") func LLVMDIBuilderCreateUnspecifiedType(
  builder: *mut void,
  name: *const int8,
  name_len: uintptr
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreatePointerType` binding with borrowed input handles/storage.
 * @returns Pointer-type metadata owned by the LLVM context.
 */
pub @extern("C") func LLVMDIBuilderCreatePointerType(
  builder: *mut void,
  pointee_ty: *mut void,
  size_in_bits: uint64,
  align_in_bits: uint32,
  address_space: uint32,
  name: *const int8,
  name_len: uintptr
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateAutoVariable` binding with borrowed input handles/storage.
 * @returns Local-variable metadata owned by the LLVM context.
 */
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

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateParameterVariable` binding with borrowed input handles/storage.
 * @returns Argument metadata owned by the LLVM context.
 */
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

/**
 * @brief Private LLVM-C `LLVMDIBuilderCreateExpression` binding with borrowed input handles/storage.
 * @returns Expression metadata owned by the LLVM context; expression storage is borrowed.
 */
pub @extern("C") func LLVMDIBuilderCreateExpression(
  builder: *mut void,
  addr: *mut void,
  length: uintptr
) -> *mut void;

/**
 * @brief Insert a variable-declaration debug record at the end of a basic block.
 * @returns Borrowed debug-variable record attached to the block; ownership remains in the containing module.
 */
pub @extern("C") func LLVMDIBuilderInsertDeclareRecordAtEnd(
  builder: *mut void,
  storage: *mut void,
  var_info: *mut void,
  expr: *mut void,
  debug_loc: *mut void,
  block: *mut void
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetBasicBlockParent` binding with borrowed input handles/storage.
 * @returns The function value containing the supplied block; lifetime belongs to its module.
 */
pub @extern("C") func LLVMGetBasicBlockParent(bb: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddFunction(LLVMModuleRef M, const char *Name, LLVMTypeRef
 *   FunctionTy);`
 * @returns The function value owned by the module.
 */
pub @extern("C") func LLVMAddFunction(m: *mut void, name: *const int8, function_ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddGlobal(LLVMModuleRef M, LLVMTypeRef Ty, const char *Name);`
 * @returns The global variable value owned by the module.
 */
pub @extern("C") func LLVMAddGlobal(m: *mut void, ty: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt1TypeInContext(LLVMContextRef C);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMInt1TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt8TypeInContext(LLVMContextRef C);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMInt8TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt32TypeInContext(LLVMContextRef C);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMInt32TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt64TypeInContext(LLVMContextRef C);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMInt64TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMVoidTypeInContext(LLVMContextRef C);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMVoidTypeInContext(c: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMPointerType(LLVMTypeRef ElementType, unsigned AddressSpace);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMPointerType(element_type: *mut void, address_space: uint32) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMFunctionType(LLVMTypeRef ReturnType, LLVMTypeRef *ParamTypes, unsigned
 *   ParamCount, LLVMBool IsVarArg);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
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
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMStructTypeInContext(
  c: *mut void,
  element_types: *mut void,
  element_count: uint32,
  packed: int32
) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMStructCreateNamed(LLVMContextRef C, const char *Name);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
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
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMArrayType(element_type: *mut void, element_count: uint32) -> *mut void;

/** @brief `LLVMTypeRef LLVMArrayType2(LLVMTypeRef ElementType, uint64_t ElementCount);`
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMArrayType2(element_type: *mut void, element_count: uint64) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMVectorType` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMVectorType(element_type: *mut void, element_count: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetParam(LLVMValueRef Fn, unsigned Index);`
 * @returns The borrowed parameter value at the valid zero-based function parameter index.
 */
pub @extern("C") func LLVMGetParam(fn: *mut void, index: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInt(LLVMTypeRef IntTy, unsigned long long N, LLVMBool
 *   SignExtend);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstInt(int_ty: *mut void, n: uint64, sign_extend: int32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPointerNull(LLVMTypeRef Ty);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstPointerNull(ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstStringInContext(LLVMContextRef C, const char *Str, unsigned
 *   Length, LLVMBool DontNullTerminate);`
 * @returns Constant value owned by the LLVM context of its type.
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
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstNamedStruct(
  struct_ty: *mut void,
  constant_vals: *mut void,
  count: uint32
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMConstStructInContext` binding with borrowed input handles/storage.
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstStructInContext(
  c: *mut void,
  constant_vals: *mut void,
  count: uint32,
  packed: int32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInBoundsGEP2(LLVMTypeRef Ty, LLVMValueRef ConstantVal,
 *   LLVMValueRef *ConstantIndices, unsigned NumIndices);`
 * @returns Constant value owned by the LLVM context of its type.
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
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstArray(
  element_ty: *mut void,
  constant_vals: *mut void,
  length: uint32
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstBitCast(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstBitCast(constant_val: *mut void, to_type: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstIntToPtr(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstIntToPtr(constant_val: *mut void, to_type: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPtrToInt(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 * @returns Constant value owned by the LLVM context of its type.
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

/**
 * @brief Set whether a global variable has thread-local storage.
 */
pub @extern("C") func LLVMSetThreadLocal(global_var: *mut void, is_thread_local: int32) -> void;

/**
 * @brief `LLVMBool LLVMIsNull(LLVMValueRef Val);`
 * @returns Nonzero when the input is a null-valued LLVM constant.
 */
pub @extern("C") func LLVMIsNull(val: *mut void) -> int32;

/**
 * @brief `LLVMBool LLVMIsConstant(LLVMValueRef Val);`
 * @returns Nonzero when the input is an LLVM constant.
 */
pub @extern("C") func LLVMIsConstant(val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMIsAConstantInt(LLVMValueRef Val);` null when `Val` is not a constant
 *   integer.
 * @returns The borrowed constant-integer value reference, or null when the value is another kind.
 */
pub @extern("C") func LLVMIsAConstantInt(val: *mut void) -> *mut void;

/**
 * @brief `unsigned long long LLVMConstIntGetZExtValue(LLVMValueRef ConstantVal);`
 * @returns The integer constant zero-extended to uint64; input must satisfy the LLVM constant-integer precondition.
 */
pub @extern("C") func LLVMConstIntGetZExtValue(constant_val: *mut void) -> uint64;

/**
 * @brief `LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef C, LLVMValueRef Fn,
 *   const char *Name);`
 * @returns A new block owned by its containing function/module.
 */
pub @extern("C") func LLVMAppendBasicBlockInContext(c: *mut void, fn: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMBuilderRef LLVMCreateBuilderInContext(LLVMContextRef C);`
 * @returns New instruction builder; release with LLVMDisposeBuilder before disposing its context.
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
 * @returns The borrowed entry block of a function that has a body.
 */
pub @extern("C") func LLVMGetEntryBasicBlock(fn: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetFirstInstruction(LLVMBasicBlockRef BB);`
 * @returns The borrowed first instruction, or null when the block is empty.
 */
pub @extern("C") func LLVMGetFirstInstruction(bb: *mut void) -> *mut void;

/**
 * @brief `void LLVMDeleteBasicBlock(LLVMBasicBlockRef BB);`
 */
pub @extern("C") func LLVMDeleteBasicBlock(bb: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMIsDeclaration(LLVMValueRef Val);` — 1 when function has no body.
 * @returns Nonzero when the global/function has no definition.
 */
pub @extern("C") func LLVMIsDeclaration(val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMGetUndef(LLVMTypeRef Ty);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMGetUndef(ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAlloca(LLVMBuilderRef, LLVMTypeRef Ty, const char *Name);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAlloca(b: *mut void, ty: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildArrayAlloca` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildArrayAlloca(
  b: *mut void,
  ty: *mut void,
  val: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildLoad2(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef PointerVal,
 *   const char *Name);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildLoad2(
  b: *mut void,
  ty: *mut void,
  pointer_val: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildStore(LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildStore(b: *mut void, val: *mut void, ptr: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const
 *   char *Name);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAdd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRet(LLVMBuilderRef, LLVMValueRef V);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildRet(b: *mut void, v: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRetVoid(LLVMBuilderRef);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildRetVoid(b: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildUnreachable` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildUnreachable(b: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildBr(LLVMBuilderRef, LLVMBasicBlockRef Dest);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildBr(b: *mut void, dest: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildCondBr(LLVMBuilderRef, LLVMValueRef If, LLVMBasicBlockRef Then,
 *   LLVMBasicBlockRef Else);`
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
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
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
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
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
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
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
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
 * @returns Owned triple text; release with LLVMDisposeMessage.
 */
pub @extern("C") func LLVMGetDefaultTargetTriple() -> *mut int8;

/**
 * @brief `LLVMBool LLVMGetTargetFromTriple(const char *Triple, LLVMTargetRef *T, char
 *   **ErrorMessage);`
 * @note `T` and `ErrorMessage` are out-pointers as `*mut void` (NY5006).
 * @returns Zero on success with a borrowed registered target; nonzero on failure with an owned error message.
 */
pub @extern("C") func LLVMGetTargetFromTriple(
  triple: *const int8,
  t: *mut void,
  error_message: *mut void
) -> int32;

/**
 * @brief `LLVMTargetMachineRef LLVMCreateTargetMachine(...);`
 * @note Level/Reloc/CodeModel are C enums passed as `int32`.
 * @returns New target machine, or null on failure; release with LLVMDisposeTargetMachine.
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

/** @brief Explicit target ABI is required for RISC-V soft/hard-float SDK separation.
 * @returns New option storage; release with LLVMDisposeTargetMachineOptions.
 */
pub @extern("C") func LLVMCreateTargetMachineOptions() -> *mut void;

/**
 * @brief Release native target-machine option storage.
 */
pub @extern("C") func LLVMDisposeTargetMachineOptions(options: *mut void);

/**
 * @brief Set target-machine CPU selection from borrowed C string text.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetCPU(options: *mut void, cpu: *const int8);

/**
 * @brief Set target-machine feature selection from borrowed C string text.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetFeatures(options: *mut void, features: *const int8);

/**
 * @brief Set the target ABI name from borrowed C string text.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetABI(options: *mut void, abi: *const int8);

/**
 * @brief Set target code-generation optimization level.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetCodeGenOptLevel(options: *mut void, level: int32);

/**
 * @brief Set target relocation mode.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetRelocMode(options: *mut void, relocation: int32);

/**
 * @brief Set target code model.
 */
pub @extern("C") func LLVMTargetMachineOptionsSetCodeModel(options: *mut void, model: int32);

/**
 * @brief Private LLVM-C `LLVMCreateTargetMachineWithOptions` binding with borrowed input handles/storage.
 * @returns New target machine, or null on failure; release with LLVMDisposeTargetMachine.
 */
pub @extern("C") func LLVMCreateTargetMachineWithOptions(
  target: *mut void,
  triple: *const int8,
  options: *mut void
) -> *mut void;

/**
 * @brief `LLVMTargetDataRef LLVMCreateTargetDataLayout(LLVMTargetMachineRef T);`
 * @returns New target-data layout; release with LLVMDisposeTargetData.
 */
pub @extern("C") func LLVMCreateTargetDataLayout(t: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeTargetData(LLVMTargetDataRef TD);`
 */
pub @extern("C") func LLVMDisposeTargetData(td: *mut void) -> void;

/** @brief `unsigned long long LLVMABISizeOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);`
 * @returns The target ABI allocation size of the type in bytes.
 */
pub @extern("C") func LLVMABISizeOfType(td: *mut void, ty: *mut void) -> uint64;

/** @brief `unsigned LLVMABIAlignmentOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);`
 * @returns The target ABI alignment of the type in bytes.
 */
pub @extern("C") func LLVMABIAlignmentOfType(td: *mut void, ty: *mut void) -> uint32;

/**
 * @brief `unsigned long long LLVMOffsetOfElement(LLVMTargetDataRef TD, LLVMTypeRef StructTy,
 *   unsigned Element);`
 * @returns The selected structure member offset in bytes under the target data layout.
 */
pub @extern("C") func LLVMOffsetOfElement(td: *mut void, struct_ty: *mut void, element: uint32) -> uint64;

/**
 * @brief `char *LLVMCopyStringRepOfTargetData(LLVMTargetDataRef TD);` — dispose with
 *   `LLVMDisposeMessage`.
 * @returns Owned layout text; release with LLVMDisposeMessage.
 */
pub @extern("C") func LLVMCopyStringRepOfTargetData(td: *mut void) -> *mut int8;

/**
 * @brief `LLVMBool LLVMTargetMachineEmitToFile(..., LLVMCodeGenFileType codegen, char
 *   **ErrorMessage);`
 * @note `codegen` `1` = `LLVMObjectFile`. `ErrorMessage` as `*mut void`.
 * @returns Zero on successful emission; nonzero on failure with an owned error message.
 */
pub @extern("C") func LLVMTargetMachineEmitToFile(
  t: *mut void,
  m: *mut void,
  filename: *const int8,
  codegen: int32,
  error_message: *mut void
) -> int32;

/**
 * @brief Private LLVM-C `LLVMInt16TypeInContext` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMInt16TypeInContext(c: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMIntTypeInContext` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMIntTypeInContext(c: *mut void, num_bits: uint32) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMFloatTypeInContext` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMFloatTypeInContext(c: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMDoubleTypeInContext` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMDoubleTypeInContext(c: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetNamedFunction` binding with borrowed input handles/storage.
 * @returns The borrowed named function value, or null when absent.
 */
pub @extern("C") func LLVMGetNamedFunction(m: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetNamedGlobal` binding with borrowed input handles/storage.
 * @returns The borrowed named global value, or null when absent.
 */
pub @extern("C") func LLVMGetNamedGlobal(m: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMTypeOf` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMTypeOf(val: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetTypeKind` binding with borrowed input handles/storage.
 * @returns The native LLVMTypeKind tag for the borrowed type.
 */
pub @extern("C") func LLVMGetTypeKind(ty: *mut void) -> int32;

/**
 * @brief Private LLVM-C `LLVMGetArrayLength2` binding with borrowed input handles/storage.
 * @returns The number of elements in the LLVM array type.
 */
pub @extern("C") func LLVMGetArrayLength2(array_ty: *mut void) -> uint64;

/**
 * @brief Private LLVM-C `LLVMGetIntTypeWidth` binding with borrowed input handles/storage.
 * @returns The bit width of the LLVM integer type.
 */
pub @extern("C") func LLVMGetIntTypeWidth(int_ty: *mut void) -> uint32;

/**
 * @brief Private LLVM-C `LLVMConstNull` binding with borrowed input handles/storage.
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstNull(ty: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMConstReal` binding with borrowed input handles/storage.
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstReal(real_ty: *mut void, n: float64) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstRealOfStringAndSize(LLVMTypeRef RealTy, const char *Str,
 *   unsigned SLen);`
 * @returns Constant value owned by the LLVM context of its type.
 */
pub @extern("C") func LLVMConstRealOfStringAndSize(
  real_ty: *mut void,
  str: *const int8,
  slen: uint32
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMConstRealGetDouble` binding with borrowed input handles/storage.
 * @returns The floating constant converted to float64; the output flag reports information loss.
 */
pub @extern("C") func LLVMConstRealGetDouble(const_val: *mut void, loses_info: *mut int32) -> float64;

/**
 * @brief Private LLVM-C `LLVMCountParamTypes` binding with borrowed input handles/storage.
 * @returns The number of parameter types in the function type.
 */
pub @extern("C") func LLVMCountParamTypes(function_ty: *mut void) -> uint32;

/**
 * @brief Write function parameter types into caller-provided storage of sufficient length.
 */
pub @extern("C") func LLVMGetParamTypes(function_ty: *mut void, dest: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMCountStructElementTypes` binding with borrowed input handles/storage.
 * @returns The number of elements in the structure type.
 */
pub @extern("C") func LLVMCountStructElementTypes(struct_ty: *mut void) -> uint32;

/**
 * @brief Private LLVM-C `LLVMStructGetTypeAtIndex` binding with borrowed input handles/storage.
 * @returns Type reference owned by its LLVM context; no independent disposal.
 */
pub @extern("C") func LLVMStructGetTypeAtIndex(struct_ty: *mut void, i: uint32) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetInsertBlock` binding with borrowed input handles/storage.
 * @returns The borrowed current insertion block, or null if no position has been set.
 */
pub @extern("C") func LLVMGetInsertBlock(builder: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSub` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSub(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildMul` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildMul(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSDiv` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildUDiv` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildUDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSRem` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSRem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildURem` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildURem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildAnd` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAnd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildOr` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildOr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildXor` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildXor(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildShl` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildShl(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildAShr` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAShr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildLShr` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildLShr(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildNeg` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildNeg(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildNot` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildNot(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFAdd` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFAdd(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFSub` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFSub(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFMul` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFMul(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFDiv` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFDiv(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFRem` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFRem(b: *mut void, lhs: *mut void, rhs: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFNeg` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFNeg(b: *mut void, v: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildICmp` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildICmp(
  b: *mut void,
  pred: int32,
  lhs: *mut void,
  rhs: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFCmp` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFCmp(
  b: *mut void,
  pred: int32,
  lhs: *mut void,
  rhs: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildTrunc` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildTrunc(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSExt` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildZExt` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildZExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFPTrunc` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFPTrunc(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFPExt` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFPExt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSIToFP` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSIToFP(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildUIToFP` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildUIToFP(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFPToSI` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFPToSI(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildFPToUI` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFPToUI(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildBitCast` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildBitCast(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildPtrToInt` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildPtrToInt(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildIntToPtr` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildIntToPtr(
  b: *mut void,
  val: *mut void,
  dest_ty: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildExtractValue` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildExtractValue(
  b: *mut void,
  agg_val: *mut void,
  index: uint32,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSelect` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSelect(
  b: *mut void,
  if_value: *mut void,
  then: *mut void,
  else_value: *mut void,
  name: *const int8
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildSwitch` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildSwitch(
  b: *mut void,
  v: *mut void,
  else_value: *mut void,
  num_cases: uint32
) -> *mut void;

/**
 * @brief Add a constant-value branch destination to a switch instruction.
 */
pub @extern("C") func LLVMAddCase(switch_value: *mut void, on_val: *mut void, dest: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMBuildPhi` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildPhi(b: *mut void, ty: *mut void, name: *const int8) -> *mut void;

/**
 * @brief Add borrowed incoming value/block pairs to a PHI instruction.
 */
pub @extern("C") func LLVMAddIncoming(
  phi: *mut void,
  incoming_values: *mut void,
  incoming_blocks: *mut void,
  count: uint32
) -> void;

/**
 * @brief `LLVMBuildFence` — `ordering` is `LLVMAtomicOrdering` (SeqCst = 7).
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildFence(
  b: *mut void,
  ordering: int32,
  single_thread: int32,
  name: *const int8
) -> *mut void;

/**
 * @brief Set instruction atomic ordering.
 */
pub @extern("C") func LLVMSetOrdering(memory_access_inst: *mut void, ordering: int32) -> void;

/**
 * @brief Select weak or strong compare-exchange semantics.
 */
pub @extern("C") func LLVMSetWeak(cmp_xchg_inst: *mut void, is_weak: int32) -> void;

/**
 * @brief Private LLVM-C `LLVMBuildAtomicRMW` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAtomicRMW(
  b: *mut void,
  op: int32,
  ptr: *mut void,
  val: *mut void,
  ordering: int32,
  single_thread: int32
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMBuildAtomicCmpXchg` binding with borrowed input handles/storage.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildAtomicCmpXchg(
  b: *mut void,
  ptr: *mut void,
  cmp: *mut void,
  new_value: *mut void,
  success_ordering: int32,
  failure_ordering: int32,
  single_thread: int32
) -> *mut void;

/** @brief `LLVMGetInlineAsm` — inline assembly value (side-effect call target).
 * @returns Inline-assembly constant owned by the function type context; text spans are borrowed.
 */
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

/**
 * @brief Private LLVM-C `LLVMGetEnumAttributeKindForName` binding with borrowed input handles/storage.
 * @returns The registered enum-attribute kind identifier, or zero for an unknown name.
 */
pub @extern("C") func LLVMGetEnumAttributeKindForName(name: *const uint8, length: uintptr) -> uint32;

/**
 * @brief Private LLVM-C `LLVMCreateEnumAttribute` binding with borrowed input handles/storage.
 * @returns Enum-attribute storage owned by the supplied LLVM context.
 */
pub @extern("C") func LLVMCreateEnumAttribute(ctx: *mut void, kind: uint32, value: uint64) -> *mut void;

/**
 * @brief Attach an attribute to the selected function return/parameter index.
 */
pub @extern("C") func LLVMAddAttributeAtIndex(fn: *mut void, index: uint32, attr: *mut void) -> void;

/**
 * @brief Attach an attribute to the selected call-site return/argument index.
 */
pub @extern("C") func LLVMAddCallSiteAttribute(call: *mut void, index: uint32, attr: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMCreateTypeAttribute` binding with borrowed input handles/storage.
 * @returns Type-attribute storage owned by the supplied LLVM context.
 */
pub @extern("C") func LLVMCreateTypeAttribute(ctx: *mut void, kind: uint32, ty: *mut void) -> *mut void;

/**
 * @brief Set alignment in bytes on the supported instruction/global.
 */
pub @extern("C") func LLVMSetAlignment(instruction: *mut void, bytes: uint32) -> void;

/**
 * @brief Private LLVM-C `LLVMGetFirstFunction` binding with borrowed input handles/storage.
 * @returns The borrowed first function, or null for a module without functions.
 */
pub @extern("C") func LLVMGetFirstFunction(mod: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetNextFunction` binding with borrowed input handles/storage.
 * @returns The borrowed next function, or null at the end of the module function list.
 */
pub @extern("C") func LLVMGetNextFunction(fn: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetLinkage` binding with borrowed input handles/storage.
 * @returns The native LLVMLinkage tag for the borrowed global value.
 */
pub @extern("C") func LLVMGetLinkage(fn: *mut void) -> int32;

/**
 * @brief Private LLVM-C `LLVMCreatePassBuilderOptions` binding with borrowed input handles/storage.
 * @returns New pass options; release with LLVMDisposePassBuilderOptions.
 */
pub @extern("C") func LLVMCreatePassBuilderOptions() -> *mut void;

/**
 * @brief Release native pass-builder option storage.
 */
pub @extern("C") func LLVMDisposePassBuilderOptions(options: *mut void) -> void;

/**
 * @brief Private LLVM-C `LLVMRunPasses` binding with borrowed input handles/storage.
 * @returns Null on success, otherwise an owned LLVM error reference; consume the error after inspection.
 */
pub @extern("C") func LLVMRunPasses(
  mod: *mut void,
  passes: *const int8,
  tm: *mut void,
  options: *mut void
) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetErrorMessage` binding with borrowed input handles/storage.
 * @returns Owned message while consuming the error reference; release with LLVMDisposeErrorMessage.
 */
pub @extern("C") func LLVMGetErrorMessage(err: *mut void) -> *mut int8;

/**
 * @brief Release owned text returned by LLVMGetErrorMessage.
 */
pub @extern("C") func LLVMDisposeErrorMessage(message: *mut int8) -> void;

/**
 * @brief Private LLVM-C `LLVMGetTypeContext` binding with borrowed input handles/storage.
 * @returns The borrowed context that owns the type.
 */
pub @extern("C") func LLVMGetTypeContext(ty: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetBasicBlockTerminator` binding with borrowed input handles/storage.
 * @returns The borrowed terminator instruction, or null when the block has none.
 */
pub @extern("C") func LLVMGetBasicBlockTerminator(block: *mut void) -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetGlobalContext` binding with borrowed input handles/storage.
 * @returns The process-wide borrowed LLVM context; callers must not dispose it.
 */
pub @extern("C") func LLVMGetGlobalContext() -> *mut void;

/**
 * @brief Private LLVM-C `LLVMGetValueName2` binding with borrowed input handles/storage.
 * @returns Borrowed value-name bytes; the output length excludes any terminator.
 */
pub @extern("C") func LLVMGetValueName2(value: *mut void, length: *mut uintptr) -> *const int8;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_add_debug_module_flags(module_ref: *mut void) -> void;

/** @brief Private provider ABI used by LlvmNative. */
pub @extern("C") func nyra_core_prepare_coff_comdats(module_ref: *mut void) -> void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Basic-type metadata owned by the LLVM context.
 */
pub @extern("C") func nyra_core_debug_basic_type(
  di_builder: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64,
  encoding: uint32
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Pointer-type metadata owned by the LLVM context.
 */
pub @extern("C") func nyra_core_debug_pointer_type(
  di_builder: *mut void,
  base_type: *mut void,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Function-pointer metadata owned by the LLVM context.
 */
pub @extern("C") func nyra_core_debug_function_pointer_type(
  di_builder: *mut void,
  file: *mut void,
  parameter_types: *mut void,
  parameter_count: uint32,
  name: *const int8,
  name_len: uintptr,
  size_bits: uint64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Fixed-array metadata owned by the LLVM context.
 */
pub @extern("C") func nyra_core_debug_array_type(
  di_builder: *mut void,
  element_type: *mut void,
  size_bits: uint64,
  align_bits: uint32,
  length: int64
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Replaceable metadata, or null on allocation failure; successful bookkeeping is linked into the
 *          caller-owned pending head.
 */
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

/** @brief Private provider ABI used by LlvmNative.
 * @returns One after appending a member, or zero for missing pending state/type or allocation failure.
 */
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

/** @brief Private provider ABI used by LlvmNative.
 * @returns Completed metadata, or null for a missing pending entry or construction failure; found entries
 *          retire their bookkeeping.
 */
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

/** @brief Private provider ABI used by LlvmNative.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildMemMove(
  builder: *mut void,
  destination: *mut void,
  destination_align: uint32,
  source: *mut void,
  source_align: uint32,
  size: *mut void
) -> *mut void;

/** @brief Private provider ABI used by LlvmNative.
 * @returns Result value in the builder context; emitted instructions are owned by their containing module.
 */
pub @extern("C") func LLVMBuildMemSet(
  builder: *mut void,
  destination: *mut void,
  byte_value: *mut void,
  size: *mut void,
  alignment: uint32
) -> *mut void;
