/**
 * @brief Product face for LLVM Target / TargetMachine / TargetData + emit helpers.
 * @note Handles are opaque; never `nyra_free`. Dispose TargetMachine / TargetData only.
 * @note DWARF / DIBuilder lives in `interface/debug_info.ni`.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

import "stdlib:stdlib.ny";
import "interface/module.ni";

/**
 * @brief Opaque wrapper around `LLVMTargetRef` (`*mut void`).
 * @note Registry-owned; do not Dispose.
 */
pub struct Target;

/**
 * @brief Opaque wrapper around `LLVMTargetMachineRef` (`*mut void`).
 */
pub struct TargetMachine;

/**
 * @brief Opaque wrapper around `LLVMTargetDataRef` (`*mut void`).
 */
pub struct TargetData;

/**
 * @brief Initialize all LLVM targets / asm printers (`nyra_llvm_initialize_all` shim).
 */
pub func InitializeAll() -> void;

/**
 * @brief Host default triple (`LLVMGetDefaultTargetTriple`); copies then disposes C buffer.
 */
pub func DefaultTargetTriple() -> string;

/**
 * @brief Look up a target (`LLVMGetTargetFromTriple`). Null handle on failure.
 */
pub static method(Target) FromTriple(triple: string) -> Target;

/**
 * @brief Create a TargetMachine for `triple` (CPU `"generic"`, empty features, defaults).
 */
pub method(Target) CreateTargetMachine(triple: string) -> TargetMachine;

/**
 * @brief Create a TargetMachine with CPU / features / opt level / code model.
 * @param opt_level LLVMCodeGenOptLevel: 0 None, 1 Less, 2 Default, 3 Aggressive.
 * @param code_model LLVMCodeModel: 0 Default, 5 Medium. RISC-V maps Small→medlow,
 *        Medium→medany, Large→medlarge — bare-metal images above 2 GiB need Medium.
 */
pub method(Target) CreateTargetMachineEx(
  triple: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0,relocation:int32=0,abi:string=""}
) -> TargetMachine;

/**
 * @brief `LLVMDisposeTargetMachine`. Do not `nyra_free`.
 */
pub method(TargetMachine) Dispose() -> void;

/**
 * @brief `LLVMCreateTargetDataLayout`; caller must `TargetData.Dispose`.
 */
pub method(TargetMachine) CreateTargetData() -> TargetData;

/**
 * @brief Emit object file (`LLVMTargetMachineEmitToFile` + `LLVMObjectFile`).
 * @returns `0` on success; nonzero on failure (message disposed).
 */
pub method(TargetMachine) EmitToFile(mod: Module, path: string) -> int32;

/**
 * @brief `LLVMDisposeTargetData`. Do not `nyra_free`.
 */
pub method(TargetData) Dispose() -> void;

/**
 * @brief Data-layout string (`LLVMCopyStringRepOfTargetData`); owns the Nyra copy.
 */
pub method(TargetData) LayoutString() -> string;

pub method(TargetData) ABISizeOfHandle(type_handle: *mut void) -> uint64;
pub method(TargetData) ABIAlignmentOfHandle(type_handle: *mut void) -> uint32;
pub method(TargetData) OffsetOfElementHandle(type_handle: *mut void, index: uint32) -> uint64;
