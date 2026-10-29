// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmType;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "interface/type.ni";

/**
 * @brief Open layout and Type helpers (Pointer / Function / StructSetBody / Array).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

/**
 * @brief Pointer type in address space 0 (`LLVMPointerType`).
 * @param elem Pointee type.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub static method(Type) Pointer(elem: Type) -> Type {
  let handle: *mut void = LLVMPointerType(elem.handle, 0 as uint32);

  return Type{handle: handle};
}

/**
 * @brief Function type (`LLVMFunctionType`); packs `params` to `LLVMTypeRef*` + count.
 * @param ret Return type.
 * @param params Parameter types in order (borrowed via `*mut`; caller owns the Array).
 * @param is_var_arg `LLVMBool` 0/1.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub static method(Type) Function(ret: Type, params: *mut Array<Type>, is_var_arg: int32) -> Type {
  unsafe {
    let n: int32 = (*params).len;
    if n <= 0 {
      let handle: *mut void = LLVMFunctionType(ret.handle, 0 as *mut void, 0 as uint32, is_var_arg);

      return Type{handle: handle};
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let ty: Type = (*params).buf[i];
      refs[i] = ty.handle;
      i = i + 1;
    }

    let param_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMFunctionType(ret.handle, param_refs, n as uint32, is_var_arg);

    return Type{handle: handle};
  }
}

/**
 * @brief `LLVMStructSetBody(self, fields, packed)`.
 */
pub method(Type) StructSetBody(fields: *mut Array<Type>, packed: int32) -> void {
  unsafe {
    let n: int32 = (*fields).len;
    if n <= 0 {
      LLVMStructSetBody(self.handle, 0 as *mut void, 0 as uint32, packed);
      return;
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let ty: Type = (*fields).buf[i];
      refs[i] = ty.handle;
      i = i + 1;
    }

    let field_refs: *mut void = (&mut refs[0]) as *mut void;
    LLVMStructSetBody(self.handle, field_refs, n as uint32, packed);
  }
}

/**
 * @brief Fixed array type (`LLVMArrayType`).
 * @param elem Element type.
 * @param n Element count (`unsigned`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub static method(Type) Array(elem: Type, n: uint32) -> Type {
  let handle: *mut void = LLVMArrayType(elem.handle, n);

  return Type{handle: handle};
}

/**
 * @brief Fixed array type using LLVM's full 64-bit element count.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub static method(Type) Array64(elem: Type, n: uint64) -> Type {
  let handle: *mut void = LLVMArrayType2(elem.handle, n);

  return Type{handle: handle};
}

/**
 * @brief Fixed-length LLVM vector type (`LLVMVectorType`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub static method(Type) Vector(elem: Type, n: uint32) -> Type {
  let handle: *mut void = LLVMVectorType(elem.handle, n);

  return Type{handle: handle};
}

/**
 * @brief `LLVMGetTypeKind` (Integer=8, Function=9, Struct=10, Array=11, Pointer=12, Float=2,
 *   Double=3).
 * @returns `LLVMGetTypeKind` (Integer=8, Function=9, Struct=10, Array=11, Pointer=12, Float=2,
 *   Double=3).
 */
pub method(Type) Kind() -> int32 {
  return LLVMGetTypeKind(self.handle);
}

/**
 * @brief `LLVMGetIntTypeWidth` (integer types only).
 * @returns `LLVMGetIntTypeWidth` (integer types only).
 */
pub method(Type) IntWidth() -> uint32 {
  return LLVMGetIntTypeWidth(self.handle);
}

/**
 * @brief `LLVMCountStructElementTypes`.
 * @returns `LLVMCountStructElementTypes`.
 */
pub method(Type) StructElementCount() -> uint32 {
  return LLVMCountStructElementTypes(self.handle);
}

pub method(Type) ArrayLength() -> uint64 {
  return LLVMGetArrayLength2(self.handle);
}

/**
 * @brief `LLVMStructGetTypeAtIndex`.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Type) StructElement(i: uint32) -> Type {
  let handle: *mut void = LLVMStructGetTypeAtIndex(self.handle, i);

  return Type{handle: handle};
}

/**
 * @brief `LLVMCountParamTypes` (function types).
 * @returns `LLVMCountParamTypes` (function types).
 */
pub method(Type) ParamCount() -> uint32 {
  return LLVMCountParamTypes(self.handle);
}

/**
 * @brief `LLVMGetParamTypes` slot `i` (copies all then indexes).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Type) ParamType(i: uint32) -> Type {
  let n: uint32 = LLVMCountParamTypes(self.handle);
  if n == (0 as uint32) {
    return Type{handle: 0 as *mut void};
  }

  unsafe {
    var refs: owned <*mut void>[] = new <*mut void>[n as int32];
    let dest: *mut void = (&mut refs[0]) as *mut void;
    LLVMGetParamTypes(self.handle, dest);
    let handle: *mut void = refs[i as int32];

    return Type{handle: handle};
  }
}
