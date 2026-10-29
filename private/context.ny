// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmContext;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "private/c_string.ny";
import "interface/context.ni";

/**
 * @brief Module main for package `llvm` wrappers + Context Create/Dispose/types/BB.
 * @note LLVM-C decls and other faces live in `part` files of module `Llvm`.
 * @see docs/design/compiler/nyra-llvm.md §1.3 · §1.5
 */

/**
 * @brief Allocate a new LLVM context (`LLVMContextCreate`).
 * @returns Context owning the foreign handle; caller must `Dispose`.
 */
pub static method(Context) Create() -> Context {
  let handle: *mut void = LLVMContextCreate();

  return Context{handle: handle};
}

/**
 * @brief `LLVMContextDispose(self.handle)`. Does not `nyra_free`.
 */
pub method(Context) Dispose() -> void {
  if self.handle == LLVMGetGlobalContext() {
    return;
  }

  LLVMContextDispose(self.handle);
}

/**
 * @brief Create a metadata string value in this context.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) MetadataString(value: string) -> Value {
  var cvalue: owned <int8>[] = LlvmCStringBuffer(value);
  let handle: *mut void = LLVMMDStringInContext(
    self.handle,
    (&mut cvalue[0]) as *const int8,
    value.length as uint32
  );

  return Value{handle: handle};
}

/**
 * @brief Create the six-field metadata tuple used by the profile site registry.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileSiteMetadata(
  site_id: Value,
  symbol_name: Value,
  path: Value,
  line: Value,
  dimensions: Value,
  tag: Value
) -> Value {
  var values: owned <*mut void>[] = new <*mut void>[6];
  values[0] = site_id.handle;
  values[1] = symbol_name.handle;
  values[2] = path.handle;
  values[3] = line.handle;
  values[4] = dimensions.handle;
  values[5] = tag.handle;
  let handle: *mut void = LLVMMDNodeInContext(self.handle,(&mut values[0]) as *mut void, 6 as uint32);

  return Value{handle: handle};
}

/**
 * @brief Create the seven-field RC operation-site row used by `!nyra.profile.rc.sites`.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileRcSiteMetadata(
  site_id: Value,
  type_id: Value,
  symbol_name: Value,
  type_name: Value,
  operation: Value,
  path: Value,
  line: Value
) -> Value {
  var values: owned <*mut void>[] = new <*mut void>[7];
  values[0] = site_id.handle;
  values[1] = type_id.handle;
  values[2] = symbol_name.handle;
  values[3] = type_name.handle;
  values[4] = operation.handle;
  values[5] = path.handle;
  values[6] = line.handle;
  let handle: *mut void = LLVMMDNodeInContext(self.handle,(&mut values[0]) as *mut void, 7 as uint32);

  return Value{handle: handle};
}

/**
 * @brief Create a two-field RC type registry row used by `!nyra.profile.rc.types`.
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ProfileRcTypeMetadata(type_id: Value, type_name: Value) -> Value {
  var values: owned <*mut void>[] = new <*mut void>[2];
  values[0] = type_id.handle;
  values[1] = type_name.handle;
  let handle: *mut void = LLVMMDNodeInContext(self.handle,(&mut values[0]) as *mut void, 2 as uint32);

  return Value{handle: handle};
}

/**
 * @brief `i1` type in this context (`LLVMInt1TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int1Type() -> Type {
  let handle: *mut void = LLVMInt1TypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief `i8` type in this context (`LLVMInt8TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int8Type() -> Type {
  let handle: *mut void = LLVMInt8TypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief `i16` type in this context (`LLVMInt16TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int16Type() -> Type {
  let handle: *mut void = LLVMInt16TypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief Integer type with `n` bits (`LLVMIntTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) IntType(n: uint32) -> Type {
  let handle: *mut void = LLVMIntTypeInContext(self.handle, n);

  return Type{handle: handle};
}

/**
 * @brief `i32` type in this context (`LLVMInt32TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int32Type() -> Type {
  let handle: *mut void = LLVMInt32TypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief `i64` type in this context (`LLVMInt64TypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) Int64Type() -> Type {
  let handle: *mut void = LLVMInt64TypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief Void type in this context (`LLVMVoidTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) VoidType() -> Type {
  let handle: *mut void = LLVMVoidTypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief `float` type (`LLVMFloatTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) FloatType() -> Type {
  let handle: *mut void = LLVMFloatTypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief `double` type (`LLVMDoubleTypeInContext`).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) DoubleType() -> Type {
  let handle: *mut void = LLVMDoubleTypeInContext(self.handle);

  return Type{handle: handle};
}

/**
 * @brief Unnamed struct type (`LLVMStructTypeInContext`); packs fields to C array.
 * @param fields Element types (borrowed; caller owns the Array).
 * @param packed `LLVMBool` 0/1.
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) StructType(fields: *mut Array<Type>, packed: int32) -> Type {
  unsafe {
    let n: int32 = (*fields).len;
    if n <= 0 {
      let handle: *mut void = LLVMStructTypeInContext(self.handle, 0 as *mut void, 0 as uint32, packed);

      return Type{handle: handle};
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let ty: Type = (*fields).buf[i];
      refs[i] = ty.handle;
      i = i + 1;
    }

    let field_refs: *mut void = (&mut refs[0]) as *mut void;
    let handle: *mut void = LLVMStructTypeInContext(self.handle, field_refs, n as uint32, packed);

    return Type{handle: handle};
  }
}

/**
 * @brief Named opaque struct (`LLVMStructCreateNamed`); fill with `Type.StructSetBody`.
 * @param name Struct name (NUL-terminated C string crossing).
 * @returns LLVM type handle whose storage remains owned by its context.
 */
pub method(Context) StructCreateNamed(name: string) -> Type {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMStructCreateNamed(self.handle,(&mut cname[0]) as *const int8);

  return Type{handle: handle};
}

/**
 * @brief Append a basic block to `fn` (`LLVMAppendBasicBlockInContext`).
 * @param fn Function value.
 * @param name Block name.
 * @returns Borrowed LLVM basic-block handle; its enclosing module owns the foreign storage.
 */
pub method(Context) AppendBasicBlock(fn: Value, name: string) -> BasicBlock {
  var cname: owned <int8>[] = LlvmCStringBuffer(name);
  let handle: *mut void = LLVMAppendBasicBlockInContext(
    self.handle,
    fn.handle,
    (&mut cname[0]) as *const int8
  );

  return BasicBlock{handle: handle};
}

/**
 * @brief String constant in this context (`LLVMConstStringInContext`).
 * @param s Payload bytes (length = `s.length`).
 * @param add_null `LLVMBool` 1 → append NUL (DontNullTerminate = 0).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ConstString(s: string, add_null: int32) -> Value {
  var dont_null: int32 = 1;
  if add_null != 0 {
    dont_null = 0;
  }

  let handle: *mut void = LLVMConstStringInContext(
    self.handle, s.data as *const int8, s.length as uint32, dont_null
  );

  return Value{handle: handle};
}

/**
 * @brief Create a literal LLVM struct constant (`LLVMConstStructInContext`).
 * @returns LLVM value handle whose storage remains owned by its context or module.
 */
pub method(Context) ConstStruct(elems: *mut Array<Value>, packed: int32) -> Value {
  unsafe {
    let n: int32 = (*elems).len;
    if n <= 0 {
      return Value{handle: LLVMConstStructInContext(self.handle, 0 as *mut void, 0 as uint32, packed)};
    }

    var refs: owned <*mut void>[] = new <*mut void>[n];
    var i: int32 = 0;
    while i < n {
      let value: Value = (*elems).buf[i];
      refs[i] = value.handle;
      i = i + 1;
    }

    return Value{handle: LLVMConstStructInContext(
      self.handle,
      (&mut refs[0]) as *mut void,
      n as uint32,
      packed
    )};
  }
}

/**
 * @brief Borrow the process-lifetime context; Dispose on this handle is a no-op.
 * @returns Borrowed process-lifetime context; Dispose is a no-op for this handle.
 */
pub static method(Context) Global() -> Context {
  return Context{handle: LLVMGetGlobalContext()};
}
