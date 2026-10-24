/** LLVM DWARF builder facade. State is an opaque native handle. */
import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/module.ni";
import "interface/value.ni";
import "interface/builder.ni";

pub func DebugInfoCreate(ctx: Context, mod: Module, source_path: string, optimized: bool) -> intptr;
pub func DebugInfoAttachFunction(state: intptr, fn_value: Value, name: string, line: int32, optimized: bool) -> void;
pub func DebugInfoSetLocation(state: intptr, builder: Builder, line: int32) -> void;
pub func DebugInfoDeclare(state: intptr, builder: Builder, slot: Value, name: string, typ: string, line: int32, arg_no: int32) -> void;
pub func DebugInfoFinalize(state: intptr) -> void;
pub func DebugInfoDispose(state: intptr) -> void;
