/**
 * @brief Module main for package `llvm` wrappers + Context Create/Dispose/types/BB.
 * @note LLVM-C decls and other faces live in `part` files of module `Llvm`.
 * @see docs/design/compiler/nyra-llvm.md §1.3 · §1.5
 */

module Llvm;
part "type.ny";
part "value.ny";
part "basic_block.ny";
part "module.ny";
part "builder.ny";
part "target.ny";
part "../private/llvm_c.ny";
part "../tests/context_selftest.ny";
part "../tests/builder_selftest.ny";
part "../tests/emit_selftest.ny";

import "stdlib:stdlib.ny";
import "ntest:ntest.ny";
import "interface/context.ni";
import "interface/type.ni";
import "interface/value.ni";
import "interface/basic_block.ni";
import "interface/module.ni";
import "interface/builder.ni";
import "interface/target.ni";

/**
 * @brief Opaque wrapper: `handle` holds `LLVMContextRef` as `*mut void`.
 */
pub struct Context {
  handle: *mut void;
}

/**
 * @brief `LLVMContextCreate` → wrapper. Caller must `Dispose`.
 */
pub static method(Context) Create() -> Context {
  let handle: *mut void = LLVMContextCreate();
  return Context{ handle: handle };
}

/**
 * @brief `LLVMContextDispose(self.handle)`. Does not `nyra_free`.
 */
pub method(Context) Dispose() -> void {
  if self.handle == LLVMGetGlobalContext() { return; }
  LLVMContextDispose(self.handle);
}

/** Create an LLVM metadata string (legacy LLVM-C value representation). */
pub method(Context) MetadataString(value: string) -> Value {
  var cvalue: owned <int8>[] = llvm_cstr_buf(value);
  let handle: *mut void = LLVMMDStringInContext(self.handle, (&mut cvalue[0]) as *const int8, value.length as uint32);
  return Value{ handle: handle };
}

/** Create a metadata tuple with the six fields used by `nyra.profile.sites`. */
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
  let handle: *mut void = LLVMMDNodeInContext(self.handle, (&mut values[0]) as *mut void, 6 as uint32);
  return Value{ handle: handle };
}

/** Create a six-field RC operation-site row for `!nyra.profile.rc.sites`. */
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
  let handle: *mut void = LLVMMDNodeInContext(self.handle, (&mut values[0]) as *mut void, 7 as uint32);
  return Value{ handle: handle };
}

/** Create a two-field type registry row for `!nyra.profile.rc.types`. */
pub method(Context) ProfileRcTypeMetadata(type_id: Value, type_name: Value) -> Value {
  var values: owned <*mut void>[] = new <*mut void>[2];
  values[0] = type_id.handle;
  values[1] = type_name.handle;
  let handle: *mut void = LLVMMDNodeInContext(self.handle, (&mut values[0]) as *mut void, 2 as uint32);
  return Value{ handle: handle };
}

/**
 * @brief `LLVMInt1TypeInContext`.
 */
pub method(Context) Int1Type() -> Type {
  let handle: *mut void = LLVMInt1TypeInContext(self.handle);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMInt8TypeInContext`.
 */
pub method(Context) Int8Type() -> Type {
  let handle: *mut void = LLVMInt8TypeInContext(self.handle);
  return Type{ handle: handle };
}

pub method(Context) Int16Type() -> Type {
  let handle: *mut void = LLVMInt16TypeInContext(self.handle);
  return Type{ handle: handle };
}

pub method(Context) IntType(n: uint32) -> Type {
  let handle: *mut void = LLVMIntTypeInContext(self.handle, n);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMInt32TypeInContext`.
 */
pub method(Context) Int32Type() -> Type {
  let handle: *mut void = LLVMInt32TypeInContext(self.handle);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMInt64TypeInContext`.
 */
pub method(Context) Int64Type() -> Type {
  let handle: *mut void = LLVMInt64TypeInContext(self.handle);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMVoidTypeInContext`.
 */
pub method(Context) VoidType() -> Type {
  let handle: *mut void = LLVMVoidTypeInContext(self.handle);
  return Type{ handle: handle };
}

pub method(Context) FloatType() -> Type {
  let handle: *mut void = LLVMFloatTypeInContext(self.handle);
  return Type{ handle: handle };
}

pub method(Context) DoubleType() -> Type {
  let handle: *mut void = LLVMDoubleTypeInContext(self.handle);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMStructTypeInContext` with Nyra `Array` → C pointer+count.
 */
pub method(Context) StructType(fields: *mut Array<Type>, packed: int32) -> Type {
  unsafe {
    let n: int32 = (*fields).len;
    if n <= 0 {
      let handle: *mut void = LLVMStructTypeInContext(self.handle, 0 as *mut void, 0 as uint32, packed);
      return Type{ handle: handle };
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
    return Type{ handle: handle };
  }
}

/**
 * @brief `LLVMStructCreateNamed`.
 */
pub method(Context) StructCreateNamed(name: string) -> Type {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMStructCreateNamed(self.handle, (&mut cname[0]) as *const int8);
  return Type{ handle: handle };
}

/**
 * @brief `LLVMAppendBasicBlockInContext`.
 */
pub method(Context) AppendBasicBlock(fn: Value, name: string) -> BasicBlock {
  var cname: owned <int8>[] = llvm_cstr_buf(name);
  let handle: *mut void = LLVMAppendBasicBlockInContext(self.handle, fn.handle, (&mut cname[0]) as *const int8);
  return BasicBlock{ handle: handle };
}

/**
 * @brief `LLVMConstStringInContext`; `add_null` inverted to DontNullTerminate.
 */
pub method(Context) ConstString(s: string, add_null: int32) -> Value {
  var dont_null: int32 = 1;
  if add_null != 0 {
    dont_null = 0;
  }
  let handle: *mut void = LLVMConstStringInContext(
    self.handle, s.data as *const int8, s.length as uint32, dont_null
  );
  return Value{ handle: handle };
}

/** `LLVMConstStructInContext` with a borrowed Nyra value array. */
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
    return Value{handle: LLVMConstStructInContext(self.handle, (&mut refs[0]) as *mut void, n as uint32, packed)};
  }
}

pub static method(Context) Global() -> Context {
  return Context{ handle: LLVMGetGlobalContext() };
}
