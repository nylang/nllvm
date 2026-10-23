/**
 * @brief Open layout and Value helpers (Param / constants / global setters).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief Opaque wrapper: `handle` holds `LLVMValueRef` as `*mut void`.
 */
pub struct Value {
  handle: *mut void;
}

/**
 * @brief `LLVMGetParam(self, i)`.
 */
pub method(Value) Param(i: int32) -> Value {
  let handle: *mut void = LLVMGetParam(self.handle, i as uint32);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMGetUndef`.
 */
pub static method(Value) ConstUndef(ty: Type) -> Value {
  let handle: *mut void = LLVMGetUndef(ty.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMConstInt`.
 */
pub static method(Value) ConstInt(ty: Type, n: uint64, sign_extend: int32) -> Value {
  let handle: *mut void = LLVMConstInt(ty.handle, n, sign_extend);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMConstPointerNull`.
 */
pub static method(Value) ConstPointerNull(ty: Type) -> Value {
  let handle: *mut void = LLVMConstPointerNull(ty.handle);
  return Value{ handle: handle };
}

pub static method(Value) ConstNull(ty: Type) -> Value {
  let handle: *mut void = LLVMConstNull(ty.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMIsNull`. True for a constant null, including `ConstantPointerNull`.
 */
pub method(Value) IsNull() -> bool {
  return LLVMIsNull(self.handle) != 0;
}

/** @brief `LLVMIsConstant`. */
pub method(Value) IsConstant() -> bool {
  return LLVMIsConstant(self.handle) != 0;
}

/**
 * @brief `LLVMIsAConstantInt` is non-null.
 */
pub method(Value) IsConstInt() -> bool {
  return LLVMIsAConstantInt(self.handle) != (0 as *mut void);
}

/**
 * @brief `LLVMConstIntGetZExtValue`. Caller has checked `IsConstInt`.
 */
pub method(Value) ConstIntZExt() -> uint64 {
  return LLVMConstIntGetZExtValue(self.handle);
}

pub static method(Value) ConstReal(ty: Type, n: float64) -> Value {
  let handle: *mut void = LLVMConstReal(ty.handle, n);
  return Value{ handle: handle };
}

pub static method(Value) ConstRealFromString(ty: Type, text: string) -> Value {
  let handle: *mut void = LLVMConstRealOfStringAndSize(ty.handle, text.data as *const int8, text.length as uint32);
  return Value{ handle: handle };
}

pub method(Value) ConstRealGetDouble() -> float64 {
  var loses_info: int32 = 0;
  return LLVMConstRealGetDouble(self.handle, &mut loses_info);
}

pub method(Value) TypeOf() -> Type {
  let handle: *mut void = LLVMTypeOf(self.handle);
  return Type{ handle: handle };
}

pub method(Value) AddCase(on_val: Value, dest: BasicBlock) -> void {
  LLVMAddCase(self.handle, on_val.handle, dest.handle);
}

pub method(Value) AddIncoming(vals: *mut Array<Value>, blocks: *mut Array<BasicBlock>) -> void {
  unsafe {
    let n: int32 = (*vals).len;
    if n <= 0 {
      return;
    }
    var vrefs: owned <*mut void>[] = new <*mut void>[n];
    var brefs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*vals).buf[i];
      let b: BasicBlock = (*blocks).buf[i];
      vrefs[i] = v.handle;
      brefs[i] = b.handle;
      i = i + 1;
    }
    LLVMAddIncoming(self.handle, (&mut vrefs[0]) as *mut void, (&mut brefs[0]) as *mut void, n as uint32);
  }
}

/**
 * @brief `LLVMConstNamedStruct` with Nyra `Array` → C pointer+count.
 */
pub static method(Value) ConstNamedStruct(ty: Type, elems: *mut Array<Value>) -> Value {
  unsafe {
    let n: int32 = (*elems).len;
    if n <= 0 {
      let handle: *mut void = LLVMConstNamedStruct(ty.handle, 0 as *mut void, 0 as uint32);
      return Value{ handle: handle };
    }
    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*elems).buf[i];
      refs[i] = v.handle;
      i = i + 1;
    }
    let elem_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMConstNamedStruct(ty.handle, elem_refs, n as uint32);
    return Value{ handle: handle };
  }
}

/**
 * @brief `LLVMConstInBoundsGEP2` with Nyra `Array` → C pointer+count.
 */
pub static method(Value) ConstInBoundsGEP(ty: Type, base: Value, indices: *mut Array<Value>) -> Value {
  unsafe {
    let n: int32 = (*indices).len;
    if n <= 0 {
      let handle: *mut void = LLVMConstInBoundsGEP2(ty.handle, base.handle, 0 as *mut void, 0 as uint32);
      return Value{ handle: handle };
    }
    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*indices).buf[i];
      refs[i] = v.handle;
      i = i + 1;
    }
    let idx_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMConstInBoundsGEP2(ty.handle, base.handle, idx_refs, n as uint32);
    return Value{ handle: handle };
  }
}

/**
 * @brief `LLVMConstArray` with Nyra `Array` → C pointer+count.
 */
pub static method(Value) ConstArray(elem_ty: Type, elems: *mut Array<Value>) -> Value {
  unsafe {
    let n: int32 = (*elems).len;
    if n <= 0 {
      let handle: *mut void = LLVMConstArray(elem_ty.handle, 0 as *mut void, 0 as uint32);
      return Value{ handle: handle };
    }
    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let v: Value = (*elems).buf[i];
      refs[i] = v.handle;
      i = i + 1;
    }
    let elem_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMConstArray(elem_ty.handle, elem_refs, n as uint32);
    return Value{ handle: handle };
  }
}

/**
 * @brief `LLVMConstBitCast`.
 */
pub static method(Value) ConstBitCast(v: Value, to: Type) -> Value {
  let handle: *mut void = LLVMConstBitCast(v.handle, to.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMConstIntToPtr`.
 */
pub static method(Value) ConstIntToPtr(v: Value, to: Type) -> Value {
  let handle: *mut void = LLVMConstIntToPtr(v.handle, to.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMConstPtrToInt`.
 */
pub static method(Value) ConstPtrToInt(v: Value, to: Type) -> Value {
  let handle: *mut void = LLVMConstPtrToInt(v.handle, to.handle);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMSetInitializer`.
 */
pub method(Value) SetInitializer(v: Value) -> void {
  LLVMSetInitializer(self.handle, v.handle);
}

/**
 * @brief `LLVMSetLinkage`.
 */
pub method(Value) SetLinkage(kind: int32) -> void {
  LLVMSetLinkage(self.handle, kind);
}

/**
 * @brief `LLVMSetOrdering` — atomic load/store ordering.
 */
pub method(Value) SetOrdering(ordering: int32) -> void {
  LLVMSetOrdering(self.handle, ordering);
}

/**
 * @brief `LLVMSetWeak` — weak vs strong cmpxchg.
 */
pub method(Value) SetWeak(is_weak: int32) -> void {
  LLVMSetWeak(self.handle, is_weak);
}

/**
 * @brief `LLVMSetGlobalConstant`.
 */
pub method(Value) SetGlobalConstant(b: int32) -> void {
  LLVMSetGlobalConstant(self.handle, b);
}

pub method(Value) SetThreadLocal(b: int32) -> void {
  LLVMSetThreadLocal(self.handle, b);
}

/**
 * @brief True when a function value already has an entry basic block (body present).
 */
pub method(Value) HasEntryBlock() -> bool {
  let entry: *mut void = LLVMGetEntryBasicBlock(self.handle);
  return entry != (0 as *mut void);
}

/**
 * @brief True when this function is still a declaration (no body) — peer `LLVMIsDeclaration`.
 */
pub method(Value) IsDeclaration() -> bool {
  return LLVMIsDeclaration(self.handle) != 0;
}

/**
 * @brief True when entry exists and contains at least one instruction (real body).
 */
pub method(Value) HasEntryCode() -> bool {
  if self.IsDeclaration() {
    return false;
  }
  let entry: *mut void = LLVMGetEntryBasicBlock(self.handle);
  if entry == (0 as *mut void) {
    return false;
  }
  let first: *mut void = LLVMGetFirstInstruction(entry);
  return first != (0 as *mut void);
}

/**
 * @brief Delete an empty entry basic block so a linkonce_odr body can be refilled.
 * @note An empty entry makes `LLVMIsDeclaration` false but is not a real body.
 */
/**
 * @brief Peer Go `llvm.InlineAsm` (ATT dialect, hasSideEffects=true for stmt asm).
 */
pub static method(Value) InlineAsm(
  ft: Type,
  asm_text: string,
  constraints: string,
  has_side_effects: int32,
  is_align_stack: int32,
  dialect: int32,
  can_throw: int32
) -> Value {
  var casm: owned <int8>[] = llvm_cstr_buf(asm_text);
  var ccons: owned <int8>[] = llvm_cstr_buf(constraints);
  let handle: *mut void = LLVMGetInlineAsm(
    ft.handle,
    (&mut casm[0]) as *const int8,
    asm_text.length as uint64,
    (&mut ccons[0]) as *const int8,
    constraints.length as uint64,
    has_side_effects,
    is_align_stack,
    dialect,
    can_throw
  );
  return Value{ handle: handle };
}

pub method(Value) DeleteEmptyEntryBlock() -> void {
  let entry: *mut void = LLVMGetEntryBasicBlock(self.handle);
  if entry == (0 as *mut void) {
    return;
  }
  let first: *mut void = LLVMGetFirstInstruction(entry);
  if first != (0 as *mut void) {
    return;
  }
  LLVMDeleteBasicBlock(entry);
}

pub method(Value) AddFunctionEnumAttribute(name: string, value: uint64) -> bool {
  let kind: uint32 = LLVMGetEnumAttributeKindForName(name.data, name.length as uintptr);
  if kind == (0 as uint32) { return false; }
  let attr: *mut void = LLVMCreateEnumAttribute(LLVMGetTypeContext(LLVMTypeOf(self.handle)), kind, value);
  LLVMAddAttributeAtIndex(self.handle, 0xffffffffu32, attr);
  return true;
}

pub method(Value) AddEnumAttributeAtIndex(index: uint32, name: string, value: uint64) -> bool {
  let kind: uint32 = LLVMGetEnumAttributeKindForName(name.data, name.length as uintptr);
  if kind == (0 as uint32) { return false; }
  let attr: *mut void = LLVMCreateEnumAttribute(LLVMGetTypeContext(LLVMTypeOf(self.handle)), kind, value);
  LLVMAddAttributeAtIndex(self.handle, index, attr);
  return true;
}

pub method(Value) AddCallSiteEnumAttribute(index: uint32, name: string, value: uint64) -> bool {
  let kind: uint32 = LLVMGetEnumAttributeKindForName(name.data, name.length as uintptr);
  if kind == (0 as uint32) { return false; }
  let attr: *mut void = LLVMCreateEnumAttribute(LLVMGetTypeContext(LLVMTypeOf(self.handle)), kind, value);
  LLVMAddCallSiteAttribute(self.handle, index, attr);
  return true;
}

pub method(Value) AddTypeAttributeAtIndex(index: uint32, name: string, type_handle: *mut void) -> bool {
  let kind: uint32 = LLVMGetEnumAttributeKindForName(name.data, name.length as uintptr);
  if kind == (0 as uint32) { return false; }
  let attr: *mut void = LLVMCreateTypeAttribute(LLVMGetTypeContext(LLVMTypeOf(self.handle)), kind, type_handle);
  LLVMAddAttributeAtIndex(self.handle, index, attr);
  return true;
}

pub method(Value) AddCallSiteTypeAttribute(index: uint32, name: string, type_handle: *mut void) -> bool {
  let kind: uint32 = LLVMGetEnumAttributeKindForName(name.data, name.length as uintptr);
  if kind == (0 as uint32) { return false; }
  let attr: *mut void = LLVMCreateTypeAttribute(LLVMGetTypeContext(LLVMTypeOf(self.handle)), kind, type_handle);
  LLVMAddCallSiteAttribute(self.handle, index, attr);
  return true;
}

pub method(Value) SetAlignment(bytes: uint32) -> void {
  LLVMSetAlignment(self.handle, bytes);
}
