/**
 * @brief Product face for LLVM `LLVMModuleRef` — Create / Dispose / Verify / AddFunction / EmitObject.
 * @note Handle is opaque; never `nyra_free`. Pair every Create with Dispose.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/type.ni";
import "interface/value.ni";

/**
 * @brief Opaque wrapper around `LLVMModuleRef` (`*mut void`).
 */
pub struct Module;

/**
 * @brief Create a module in `ctx` (`LLVMModuleCreateWithNameInContext`).
 * @param ctx Owning context.
 * @param name Module id (NUL-terminated C string crossing).
 */
pub static method(Module) Create(ctx: Context, name: string) -> Module;

/**
 * @brief Destroy this module (`LLVMDisposeModule`). Do not `nyra_free`.
 */
pub method(Module) Dispose() -> void;

/** Add one metadata node to a named module registry. */
pub method(Module) AddNamedMetadataOperand(name: string, value: Value) -> void;

/**
 * @brief Set target triple (`LLVMSetTarget`).
 */
pub method(Module) SetTarget(triple: string) -> void;

/**
 * @brief Read target triple (`LLVMGetTarget`); empty if unset.
 */
pub method(Module) TargetTriple() -> string;

/**
 * @brief Set data layout string (`LLVMSetDataLayout`).
 */
pub method(Module) SetDataLayout(layout: string) -> void;

/**
 * @brief Verify IR (`LLVMVerifyModule` + `LLVMPrintMessageAction`).
 * @returns `0` if valid; nonzero if broken. Disposes any LLVM message.
 */
pub method(Module) Verify() -> int32;

/**
 * @brief Print LLVM IR text (`LLVMPrintModuleToFile`).
 * @returns `0` on success.
 */
pub method(Module) WriteIR(path: string) -> int32;

/**
 * @brief Add a function declaration/definition (`LLVMAddFunction`).
 * @param name Function name.
 * @param fn_ty Function type.
 * @returns Function `Value`.
 */
pub method(Module) AddFunction(name: string, fn_ty: Type) -> Value;

/**
 * @brief Lookup by name (`LLVMGetNamedFunction`); null handle if missing.
 */
pub method(Module) NamedFunction(name: string) -> Value;

/**
 * @brief Lookup global by name (`LLVMGetNamedGlobal`); null handle if missing.
 */
pub method(Module) NamedGlobal(name: string) -> Value;

/**
 * @brief Add a global variable (`LLVMAddGlobal`).
 */
pub method(Module) AddGlobal(ty: Type, name: string) -> Value;

/**
 * @brief Emit an object file for this module (`Module.EmitObject` convenience).
 * @note Uses module triple if set; otherwise host `DefaultTargetTriple`.
 * @returns `0` on success; nonzero on failure.
 */
pub method(Module) EmitObject(path: string) -> int32;

/**
 * @brief Emit ObjectUnit for an explicit triple / CPU / features / opt level.
 * @param opt_level LLVMCodeGenOptLevel 0–3.
 * @param code_model LLVMCodeModel (0 Default, 5 Medium); bare-metal above 2 GiB needs 5.
 * @returns `0` on success; nonzero on failure.
 */
pub method(Module) EmitObjectEx(
  path: string,
  triple: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0, inline_ir: bool = false,relocation:int32=0}
) -> int32;

/** LLVM's default IR optimization pipeline; 0..3, 10=Os, 11=Oz. */
pub method(Module) Optimize(triple: string, cpu: string, features: string, level: int32,{pipeline:string="",relocation:int32=0}) -> int32;
