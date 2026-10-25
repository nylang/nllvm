/**
 * @brief LLVM-C `@extern("C")` decls for package `llvm` (v1 ObjectUnit slice).
 * @note Lives in `private/` only — not barrel-exported; not `source/stdlib/private/platform.ni`.
 * @note `nyra_llvm_initialize_all` is the only C shim (Target.h macros).
 * @see docs/design/compiler/nyra-llvm.md §1.2 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief `LLVMContextRef LLVMContextCreate(void);`
 */
@extern("C") func LLVMContextCreate() -> *mut void;

/**
 * @brief `void LLVMContextDispose(LLVMContextRef C);`
 */
@extern("C") func LLVMContextDispose(C: *mut void) -> void;

/** `LLVMValueRef LLVMMDStringInContext(LLVMContextRef C, const char *Str, unsigned SLen);` */
@extern("C") func LLVMMDStringInContext(C: *mut void, Str: *const int8, SLen: uint32) -> *mut void;

/** `LLVMValueRef LLVMMDNodeInContext(LLVMContextRef C, LLVMValueRef *Vals, unsigned Count);` */
@extern("C") func LLVMMDNodeInContext(C: *mut void, Vals: *mut void, Count: uint32) -> *mut void;

/** `void LLVMAddNamedMetadataOperand(LLVMModuleRef M, const char *Name, LLVMValueRef Val);` */
@extern("C") func LLVMAddNamedMetadataOperand(M: *mut void, Name: *const int8, Val: *mut void) -> void;

/**
 * @brief `void LLVMDisposeMessage(char *Message);`
 */
@extern("C") func LLVMDisposeMessage(Message: *mut int8) -> void;

/**
 * @brief `LLVMModuleRef LLVMModuleCreateWithNameInContext(const char *ModuleID, LLVMContextRef C);`
 */
@extern("C") func LLVMModuleCreateWithNameInContext(ModuleID: *const int8, C: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeModule(LLVMModuleRef M);`
 */
@extern("C") func LLVMDisposeModule(M: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMPrintModuleToFile(LLVMModuleRef M, const char *Filename, char **ErrorMessage);`
 */
@extern("C") func LLVMPrintModuleToFile(M: *mut void, Filename: *const int8, ErrorMessage: *mut void) -> int32;

/**
 * @brief `void LLVMSetTarget(LLVMModuleRef M, const char *Triple);`
 */
@extern("C") func LLVMSetTarget(M: *mut void, Triple: *const int8) -> void;

/**
 * @brief `const char *LLVMGetTarget(LLVMModuleRef M);` — owned by module; do not dispose.
 */
@extern("C") func LLVMGetTarget(M: *mut void) -> *const int8;

/**
 * @brief `void LLVMSetDataLayout(LLVMModuleRef M, const char *DataLayoutStr);`
 */
@extern("C") func LLVMSetDataLayout(M: *mut void, DataLayoutStr: *const int8) -> void;

/**
 * @brief `LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action, char **OutMessage);`
 * @note Action `2` = `LLVMReturnStatusAction`. `OutMessage` is `char**` as `*mut void` (NY5006).
 */
@extern("C") func LLVMVerifyModule(M: *mut void, Action: int32, OutMessage: *mut void) -> int32;

// LLVM-C debug metadata entry points (llvm-c/DebugInfo.h).
@extern("C") func LLVMCreateDIBuilder(M: *mut void) -> *mut void;
@extern("C") func LLVMDIBuilderFinalize(Builder: *mut void) -> void;
@extern("C") func LLVMDisposeDIBuilder(Builder: *mut void) -> void;
@extern("C") func LLVMDIBuilderCreateFile(Builder: *mut void, Filename: *const int8, FilenameLen: uintptr, Directory: *const int8, DirectoryLen: uintptr) -> *mut void;
@extern("C") func LLVMDIBuilderCreateCompileUnit(Builder: *mut void, Lang: uint32, File: *mut void, Producer: *const int8, ProducerLen: uintptr, IsOptimized: int32, Flags: *const int8, FlagsLen: uintptr, RuntimeVer: uint32, SplitName: *const int8, SplitNameLen: uintptr, Kind: uint32, DWOId: uint32, SplitDebugInlining: int32, DebugInfoForProfiling: int32, SysRoot: *const int8, SysRootLen: uintptr, SDK: *const int8, SDKLen: uintptr) -> *mut void;
@extern("C") func LLVMDIBuilderCreateSubroutineType(Builder: *mut void, File: *mut void, ParameterTypes: *mut void, NumParameterTypes: uint32, Flags: uint32) -> *mut void;
@extern("C") func LLVMDIBuilderCreateFunction(Builder: *mut void, Scope: *mut void, Name: *const int8, NameLen: uintptr, LinkageName: *const int8, LinkageNameLen: uintptr, File: *mut void, LineNo: uint32, Ty: *mut void, IsLocalToUnit: int32, IsDefinition: int32, ScopeLine: uint32, Flags: uint32, IsOptimized: int32) -> *mut void;
@extern("C") func LLVMSetSubprogram(Func: *mut void, SP: *mut void) -> void;
@extern("C") func LLVMDIBuilderCreateDebugLocation(Ctx: *mut void, Line: uint32, Column: uint32, Scope: *mut void, InlinedAt: *mut void) -> *mut void;
@extern("C") func LLVMSetCurrentDebugLocation2(Builder: *mut void, Loc: *mut void) -> void;
@extern("C") func LLVMSetIsNewDbgInfoFormat(M: *mut void, UseNewFormat: int32) -> void;
@extern("C") func LLVMDIBuilderCreateBasicType(Builder: *mut void, Name: *const int8, NameLen: uintptr, SizeInBits: uint64, Encoding: uint32, Flags: uint32) -> *mut void;
@extern("C") func LLVMDIBuilderCreateUnspecifiedType(Builder: *mut void, Name: *const int8, NameLen: uintptr) -> *mut void;
@extern("C") func LLVMDIBuilderCreatePointerType(Builder: *mut void, PointeeTy: *mut void, SizeInBits: uint64, AlignInBits: uint32, AddressSpace: uint32, Name: *const int8, NameLen: uintptr) -> *mut void;
@extern("C") func LLVMDIBuilderCreateAutoVariable(Builder: *mut void, Scope: *mut void, Name: *const int8, NameLen: uintptr, File: *mut void, LineNo: uint32, Ty: *mut void, AlwaysPreserve: int32, Flags: uint32, AlignInBits: uint32) -> *mut void;
@extern("C") func LLVMDIBuilderCreateParameterVariable(Builder: *mut void, Scope: *mut void, Name: *const int8, NameLen: uintptr, ArgNo: uint32, File: *mut void, LineNo: uint32, Ty: *mut void, AlwaysPreserve: int32, Flags: uint32) -> *mut void;
@extern("C") func LLVMDIBuilderCreateExpression(Builder: *mut void, Addr: *mut void, Length: uintptr) -> *mut void;
@extern("C") func LLVMDIBuilderInsertDeclareRecordAtEnd(Builder: *mut void, Storage: *mut void, VarInfo: *mut void, Expr: *mut void, DebugLoc: *mut void, Block: *mut void) -> *mut void;
@extern("C") func LLVMGetBasicBlockParent(BB: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddFunction(LLVMModuleRef M, const char *Name, LLVMTypeRef FunctionTy);`
 */
@extern("C") func LLVMAddFunction(M: *mut void, Name: *const int8, FunctionTy: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMAddGlobal(LLVMModuleRef M, LLVMTypeRef Ty, const char *Name);`
 */
@extern("C") func LLVMAddGlobal(M: *mut void, Ty: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt1TypeInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMInt1TypeInContext(C: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt8TypeInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMInt8TypeInContext(C: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt32TypeInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMInt32TypeInContext(C: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMInt64TypeInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMInt64TypeInContext(C: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMVoidTypeInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMVoidTypeInContext(C: *mut void) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMPointerType(LLVMTypeRef ElementType, unsigned AddressSpace);`
 */
@extern("C") func LLVMPointerType(ElementType: *mut void, AddressSpace: uint32) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMFunctionType(LLVMTypeRef ReturnType, LLVMTypeRef *ParamTypes, unsigned ParamCount, LLVMBool IsVarArg);`
 */
@extern("C") func LLVMFunctionType(ReturnType: *mut void, ParamTypes: *mut void, ParamCount: uint32, IsVarArg: int32) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMStructTypeInContext(LLVMContextRef C, LLVMTypeRef *ElementTypes, unsigned ElementCount, LLVMBool Packed);`
 */
@extern("C") func LLVMStructTypeInContext(C: *mut void, ElementTypes: *mut void, ElementCount: uint32, Packed: int32) -> *mut void;

/**
 * @brief `LLVMTypeRef LLVMStructCreateNamed(LLVMContextRef C, const char *Name);`
 */
@extern("C") func LLVMStructCreateNamed(C: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `void LLVMStructSetBody(LLVMTypeRef StructTy, LLVMTypeRef *ElementTypes, unsigned ElementCount, LLVMBool Packed);`
 */
@extern("C") func LLVMStructSetBody(StructTy: *mut void, ElementTypes: *mut void, ElementCount: uint32, Packed: int32) -> void;

/**
 * @brief `LLVMTypeRef LLVMArrayType(LLVMTypeRef ElementType, unsigned ElementCount);`
 */
@extern("C") func LLVMArrayType(ElementType: *mut void, ElementCount: uint32) -> *mut void;
/** `LLVMTypeRef LLVMArrayType2(LLVMTypeRef ElementType, uint64_t ElementCount);` */
@extern("C") func LLVMArrayType2(ElementType: *mut void, ElementCount: uint64) -> *mut void;
@extern("C") func LLVMVectorType(ElementType: *mut void, ElementCount: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetParam(LLVMValueRef Fn, unsigned Index);`
 */
@extern("C") func LLVMGetParam(Fn: *mut void, Index: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInt(LLVMTypeRef IntTy, unsigned long long N, LLVMBool SignExtend);`
 */
@extern("C") func LLVMConstInt(IntTy: *mut void, N: uint64, SignExtend: int32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPointerNull(LLVMTypeRef Ty);`
 */
@extern("C") func LLVMConstPointerNull(Ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstStringInContext(LLVMContextRef C, const char *Str, unsigned Length, LLVMBool DontNullTerminate);`
 */
@extern("C") func LLVMConstStringInContext(C: *mut void, Str: *const int8, Length: uint32, DontNullTerminate: int32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstNamedStruct(LLVMTypeRef StructTy, LLVMValueRef *ConstantVals, unsigned Count);`
 */
@extern("C") func LLVMConstNamedStruct(StructTy: *mut void, ConstantVals: *mut void, Count: uint32) -> *mut void;
@extern("C") func LLVMConstStructInContext(C: *mut void, ConstantVals: *mut void, Count: uint32, Packed: int32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstInBoundsGEP2(LLVMTypeRef Ty, LLVMValueRef ConstantVal, LLVMValueRef *ConstantIndices, unsigned NumIndices);`
 */
@extern("C") func LLVMConstInBoundsGEP2(Ty: *mut void, ConstantVal: *mut void, ConstantIndices: *mut void, NumIndices: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstArray(LLVMTypeRef ElementTy, LLVMValueRef *ConstantVals, unsigned Length);`
 */
@extern("C") func LLVMConstArray(ElementTy: *mut void, ConstantVals: *mut void, Length: uint32) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstBitCast(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
@extern("C") func LLVMConstBitCast(ConstantVal: *mut void, ToType: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstIntToPtr(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
@extern("C") func LLVMConstIntToPtr(ConstantVal: *mut void, ToType: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMConstPtrToInt(LLVMValueRef ConstantVal, LLVMTypeRef ToType);`
 */
@extern("C") func LLVMConstPtrToInt(ConstantVal: *mut void, ToType: *mut void) -> *mut void;

/**
 * @brief `void LLVMSetInitializer(LLVMValueRef GlobalVar, LLVMValueRef ConstantVal);`
 */
@extern("C") func LLVMSetInitializer(GlobalVar: *mut void, ConstantVal: *mut void) -> void;

/**
 * @brief `void LLVMSetLinkage(LLVMValueRef Global, LLVMLinkage Linkage);`
 */
@extern("C") func LLVMSetLinkage(Global: *mut void, Linkage: int32) -> void;

/**
 * @brief `void LLVMSetGlobalConstant(LLVMValueRef GlobalVar, LLVMBool IsConstant);`
 */
@extern("C") func LLVMSetGlobalConstant(GlobalVar: *mut void, IsConstant: int32) -> void;
@extern("C") func LLVMSetThreadLocal(GlobalVar: *mut void, IsThreadLocal: int32) -> void;

/**
 * @brief `LLVMBool LLVMIsNull(LLVMValueRef Val);`
 */
@extern("C") func LLVMIsNull(Val: *mut void) -> int32;

/**
 * @brief `LLVMBool LLVMIsConstant(LLVMValueRef Val);`
 */
@extern("C") func LLVMIsConstant(Val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMIsAConstantInt(LLVMValueRef Val);` null when `Val` is not a constant integer.
 */
@extern("C") func LLVMIsAConstantInt(Val: *mut void) -> *mut void;

/**
 * @brief `unsigned long long LLVMConstIntGetZExtValue(LLVMValueRef ConstantVal);`
 */
@extern("C") func LLVMConstIntGetZExtValue(ConstantVal: *mut void) -> uint64;

/**
 * @brief `LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef C, LLVMValueRef Fn, const char *Name);`
 */
@extern("C") func LLVMAppendBasicBlockInContext(C: *mut void, Fn: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMBuilderRef LLVMCreateBuilderInContext(LLVMContextRef C);`
 */
@extern("C") func LLVMCreateBuilderInContext(C: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeBuilder(LLVMBuilderRef Builder);`
 */
@extern("C") func LLVMDisposeBuilder(Builder: *mut void) -> void;

/**
 * @brief `void LLVMPositionBuilderAtEnd(LLVMBuilderRef Builder, LLVMBasicBlockRef Block);`
 */
@extern("C") func LLVMPositionBuilderAtEnd(Builder: *mut void, Block: *mut void) -> void;

/**
 * @brief `void LLVMPositionBuilderBefore(LLVMBuilderRef Builder, LLVMValueRef Instr);`
 */
@extern("C") func LLVMPositionBuilderBefore(Builder: *mut void, Instr: *mut void) -> void;

/**
 * @brief `LLVMBasicBlockRef LLVMGetEntryBasicBlock(LLVMValueRef Fn);`
 */
@extern("C") func LLVMGetEntryBasicBlock(Fn: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMGetFirstInstruction(LLVMBasicBlockRef BB);`
 */
@extern("C") func LLVMGetFirstInstruction(BB: *mut void) -> *mut void;

/**
 * @brief `void LLVMDeleteBasicBlock(LLVMBasicBlockRef BB);`
 */
@extern("C") func LLVMDeleteBasicBlock(BB: *mut void) -> void;

/**
 * @brief `LLVMBool LLVMIsDeclaration(LLVMValueRef Val);` — 1 when function has no body.
 */
@extern("C") func LLVMIsDeclaration(Val: *mut void) -> int32;

/**
 * @brief `LLVMValueRef LLVMGetUndef(LLVMTypeRef Ty);`
 */
@extern("C") func LLVMGetUndef(Ty: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAlloca(LLVMBuilderRef, LLVMTypeRef Ty, const char *Name);`
 */
@extern("C") func LLVMBuildAlloca(B: *mut void, Ty: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildArrayAlloca(B: *mut void, Ty: *mut void, Val: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildLoad2(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name);`
 */
@extern("C") func LLVMBuildLoad2(B: *mut void, Ty: *mut void, PointerVal: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildStore(LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr);`
 */
@extern("C") func LLVMBuildStore(B: *mut void, Val: *mut void, Ptr: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);`
 */
@extern("C") func LLVMBuildAdd(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRet(LLVMBuilderRef, LLVMValueRef V);`
 */
@extern("C") func LLVMBuildRet(B: *mut void, V: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildRetVoid(LLVMBuilderRef);`
 */
@extern("C") func LLVMBuildRetVoid(B: *mut void) -> *mut void;
@extern("C") func LLVMBuildUnreachable(B: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildBr(LLVMBuilderRef, LLVMBasicBlockRef Dest);`
 */
@extern("C") func LLVMBuildBr(B: *mut void, Dest: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildCondBr(LLVMBuilderRef, LLVMValueRef If, LLVMBasicBlockRef Then, LLVMBasicBlockRef Else);`
 */
@extern("C") func LLVMBuildCondBr(B: *mut void, If: *mut void, Then: *mut void, Else: *mut void) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildCall2(LLVMBuilderRef, LLVMTypeRef, LLVMValueRef Fn, LLVMValueRef *Args, unsigned NumArgs, const char *Name);`
 */
@extern("C") func LLVMBuildCall2(B: *mut void, FnTy: *mut void, Fn: *mut void, Args: *mut void, NumArgs: uint32, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildInBoundsGEP2(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, LLVMValueRef *Indices, unsigned NumIndices, const char *Name);`
 */
@extern("C") func LLVMBuildInBoundsGEP2(B: *mut void, Ty: *mut void, PointerVal: *mut void, Indices: *mut void, NumIndices: uint32, Name: *const int8) -> *mut void;

/**
 * @brief `LLVMValueRef LLVMBuildInsertValue(LLVMBuilderRef, LLVMValueRef AggVal, LLVMValueRef EltVal, unsigned Index, const char *Name);`
 */
@extern("C") func LLVMBuildInsertValue(B: *mut void, AggVal: *mut void, EltVal: *mut void, Index: uint32, Name: *const int8) -> *mut void;

/**
 * @brief Shim: expand five `LLVMInitializeAll*` macros (`nyra_llvm_initialize_all.c`).
 */
@extern("C") func nyra_llvm_initialize_all() -> void;

/**
 * @brief `char *LLVMGetDefaultTargetTriple(void);` — dispose with `LLVMDisposeMessage`.
 */
@extern("C") func LLVMGetDefaultTargetTriple() -> *mut int8;

/**
 * @brief `LLVMBool LLVMGetTargetFromTriple(const char *Triple, LLVMTargetRef *T, char **ErrorMessage);`
 * @note `T` and `ErrorMessage` are out-pointers as `*mut void` (NY5006).
 */
@extern("C") func LLVMGetTargetFromTriple(Triple: *const int8, T: *mut void, ErrorMessage: *mut void) -> int32;

/**
 * @brief `LLVMTargetMachineRef LLVMCreateTargetMachine(...);`
 * @note Level/Reloc/CodeModel are C enums passed as `int32`.
 */
@extern("C") func LLVMCreateTargetMachine(
  T: *mut void,
  Triple: *const int8,
  CPU: *const int8,
  Features: *const int8,
  Level: int32,
  Reloc: int32,
  CodeModel: int32
) -> *mut void;

/**
 * @brief `void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);`
 */
@extern("C") func LLVMDisposeTargetMachine(T: *mut void) -> void;

/** Explicit target ABI is required for RISC-V soft/hard-float SDK separation. */
@extern("C") func LLVMCreateTargetMachineOptions() -> *mut void;
@extern("C") func LLVMDisposeTargetMachineOptions(options: *mut void);
@extern("C") func LLVMTargetMachineOptionsSetCPU(options: *mut void, cpu: *const int8);
@extern("C") func LLVMTargetMachineOptionsSetFeatures(options: *mut void, features: *const int8);
@extern("C") func LLVMTargetMachineOptionsSetABI(options: *mut void, abi: *const int8);
@extern("C") func LLVMTargetMachineOptionsSetCodeGenOptLevel(options: *mut void, level: int32);
@extern("C") func LLVMTargetMachineOptionsSetRelocMode(options: *mut void, relocation: int32);
@extern("C") func LLVMTargetMachineOptionsSetCodeModel(options: *mut void, model: int32);
@extern("C") func LLVMCreateTargetMachineWithOptions(target: *mut void, triple: *const int8, options: *mut void) -> *mut void;

/**
 * @brief `LLVMTargetDataRef LLVMCreateTargetDataLayout(LLVMTargetMachineRef T);`
 */
@extern("C") func LLVMCreateTargetDataLayout(T: *mut void) -> *mut void;

/**
 * @brief `void LLVMDisposeTargetData(LLVMTargetDataRef TD);`
 */
@extern("C") func LLVMDisposeTargetData(TD: *mut void) -> void;

/** `unsigned long long LLVMABISizeOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);` */
@extern("C") func LLVMABISizeOfType(TD: *mut void, Ty: *mut void) -> uint64;

/** `unsigned LLVMABIAlignmentOfType(LLVMTargetDataRef TD, LLVMTypeRef Ty);` */
@extern("C") func LLVMABIAlignmentOfType(TD: *mut void, Ty: *mut void) -> uint32;

/** `unsigned long long LLVMOffsetOfElement(LLVMTargetDataRef TD, LLVMTypeRef StructTy, unsigned Element);` */
@extern("C") func LLVMOffsetOfElement(TD: *mut void, StructTy: *mut void, Element: uint32) -> uint64;

/**
 * @brief `char *LLVMCopyStringRepOfTargetData(LLVMTargetDataRef TD);` — dispose with `LLVMDisposeMessage`.
 */
@extern("C") func LLVMCopyStringRepOfTargetData(TD: *mut void) -> *mut int8;

/**
 * @brief `LLVMBool LLVMTargetMachineEmitToFile(..., LLVMCodeGenFileType codegen, char **ErrorMessage);`
 * @note `codegen` `1` = `LLVMObjectFile`. `ErrorMessage` as `*mut void`.
 */
@extern("C") func LLVMTargetMachineEmitToFile(
  T: *mut void,
  M: *mut void,
  Filename: *const int8,
  codegen: int32,
  ErrorMessage: *mut void
) -> int32;

@extern("C") func LLVMInt16TypeInContext(C: *mut void) -> *mut void;
@extern("C") func LLVMIntTypeInContext(C: *mut void, NumBits: uint32) -> *mut void;
@extern("C") func LLVMFloatTypeInContext(C: *mut void) -> *mut void;
@extern("C") func LLVMDoubleTypeInContext(C: *mut void) -> *mut void;
@extern("C") func LLVMGetNamedFunction(M: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMGetNamedGlobal(M: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMTypeOf(Val: *mut void) -> *mut void;
@extern("C") func LLVMGetTypeKind(Ty: *mut void) -> int32;
@extern("C") func LLVMGetArrayLength2(ArrayTy: *mut void) -> uint64;
@extern("C") func LLVMGetIntTypeWidth(IntTy: *mut void) -> uint32;
@extern("C") func LLVMConstNull(Ty: *mut void) -> *mut void;
@extern("C") func LLVMConstReal(RealTy: *mut void, N: float64) -> *mut void;
/** `LLVMValueRef LLVMConstRealOfStringAndSize(LLVMTypeRef RealTy, const char *Str, unsigned SLen);` */
@extern("C") func LLVMConstRealOfStringAndSize(RealTy: *mut void, Str: *const int8, SLen: uint32) -> *mut void;
@extern("C") func LLVMConstRealGetDouble(ConstVal: *mut void, LosesInfo: *mut int32) -> float64;
@extern("C") func LLVMCountParamTypes(FunctionTy: *mut void) -> uint32;
@extern("C") func LLVMGetParamTypes(FunctionTy: *mut void, Dest: *mut void) -> void;
@extern("C") func LLVMCountStructElementTypes(StructTy: *mut void) -> uint32;
@extern("C") func LLVMStructGetTypeAtIndex(StructTy: *mut void, i: uint32) -> *mut void;
@extern("C") func LLVMGetInsertBlock(Builder: *mut void) -> *mut void;
@extern("C") func LLVMBuildSub(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildMul(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSDiv(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildUDiv(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSRem(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildURem(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildAnd(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildOr(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildXor(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildShl(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildAShr(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildLShr(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildNeg(B: *mut void, V: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildNot(B: *mut void, V: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFAdd(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFSub(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFMul(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFDiv(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFRem(B: *mut void, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFNeg(B: *mut void, V: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildICmp(B: *mut void, Pred: int32, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFCmp(B: *mut void, Pred: int32, LHS: *mut void, RHS: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildTrunc(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSExt(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildZExt(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFPTrunc(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFPExt(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSIToFP(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildUIToFP(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFPToSI(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildFPToUI(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildBitCast(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildPtrToInt(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildIntToPtr(B: *mut void, Val: *mut void, DestTy: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildExtractValue(B: *mut void, AggVal: *mut void, Index: uint32, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSelect(B: *mut void, If: *mut void, Then: *mut void, Else: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMBuildSwitch(B: *mut void, V: *mut void, Else: *mut void, NumCases: uint32) -> *mut void;
@extern("C") func LLVMAddCase(Switch: *mut void, OnVal: *mut void, Dest: *mut void) -> void;
@extern("C") func LLVMBuildPhi(B: *mut void, Ty: *mut void, Name: *const int8) -> *mut void;
@extern("C") func LLVMAddIncoming(Phi: *mut void, IncomingValues: *mut void, IncomingBlocks: *mut void, Count: uint32) -> void;
/**
 * @brief `LLVMBuildFence` — `ordering` is `LLVMAtomicOrdering` (SeqCst = 7).
 */
@extern("C") func LLVMBuildFence(B: *mut void, ordering: int32, singleThread: int32, Name: *const int8) -> *mut void;
@extern("C") func LLVMSetOrdering(MemoryAccessInst: *mut void, ordering: int32) -> void;
@extern("C") func LLVMSetWeak(CmpXchgInst: *mut void, IsWeak: int32) -> void;
@extern("C") func LLVMBuildAtomicRMW(B: *mut void, op: int32, PTR: *mut void, Val: *mut void, ordering: int32, singleThread: int32) -> *mut void;
@extern("C") func LLVMBuildAtomicCmpXchg(B: *mut void, Ptr: *mut void, Cmp: *mut void, New: *mut void, SuccessOrdering: int32, FailureOrdering: int32, SingleThread: int32) -> *mut void;

/** @brief `LLVMGetInlineAsm` — inline assembly value (side-effect call target). */
@extern("C") func LLVMGetInlineAsm(Ty: *mut void, AsmString: *const int8, AsmStringLength: uint64, Constraints: *const int8, ConstraintsLength: uint64, HasSideEffects: int32, IsAlignStack: int32, Dialect: int32, CanThrow: int32) -> *mut void;

@extern("C") func LLVMGetEnumAttributeKindForName(name: *const uint8, length: uintptr) -> uint32;
@extern("C") func LLVMCreateEnumAttribute(ctx: *mut void, kind: uint32, value: uint64) -> *mut void;
@extern("C") func LLVMAddAttributeAtIndex(fn: *mut void, index: uint32, attr: *mut void) -> void;
@extern("C") func LLVMAddCallSiteAttribute(call: *mut void, index: uint32, attr: *mut void) -> void;
@extern("C") func LLVMCreateTypeAttribute(ctx: *mut void, kind: uint32, ty: *mut void) -> *mut void;
@extern("C") func LLVMSetAlignment(instruction: *mut void, bytes: uint32) -> void;

@extern("C") func LLVMGetFirstFunction(mod: *mut void) -> *mut void;
@extern("C") func LLVMGetNextFunction(fn: *mut void) -> *mut void;
@extern("C") func LLVMGetLinkage(fn: *mut void) -> int32;
@extern("C") func LLVMCreatePassBuilderOptions() -> *mut void;
@extern("C") func LLVMDisposePassBuilderOptions(options: *mut void) -> void;
@extern("C") func LLVMRunPasses(mod: *mut void, passes: *const int8, tm: *mut void, options: *mut void) -> *mut void;
@extern("C") func LLVMGetErrorMessage(err: *mut void) -> *mut int8;
@extern("C") func LLVMDisposeErrorMessage(message: *mut int8) -> void;

@extern("C") func LLVMGetTypeContext(ty: *mut void) -> *mut void;
@extern("C") func LLVMGetBasicBlockTerminator(block: *mut void) -> *mut void;

@extern("C") func LLVMGetGlobalContext() -> *mut void;

@extern("C") func LLVMGetValueName2(value:*mut void,length:*mut uintptr)->*const int8;
