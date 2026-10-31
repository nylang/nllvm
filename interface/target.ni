// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

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
pub static method(Target) InitializeAll() -> void;

/**
 * @brief Host default triple (`LLVMGetDefaultTargetTriple`); copies then disposes C buffer.
 * @returns Host default triple (`LLVMGetDefaultTargetTriple`); copies then disposes C buffer.
 */
pub static method(Target) DefaultTriple() -> string;

/**
 * @brief Look up a target (`LLVMGetTargetFromTriple`). Null handle on failure.
 * @returns Registry-owned target handle, or a null handle if lookup fails.
 */
pub static method(Target) FromTriple(triple: string) -> Target;

/**
 * @brief Create a TargetMachine for `triple` (CPU `"generic"`, empty features, defaults).
 * @returns Target-machine handle to release with Dispose.
 */
pub method(Target) CreateTargetMachine(triple: string) -> TargetMachine;

/**
 * @brief Create a TargetMachine with CPU / features / opt level / code model.
 * @param opt_level LLVMCodeGenOptLevel: 0 None, 1 Less, 2 Default, 3 Aggressive.
 * @param code_model LLVMCodeModel: 0 Default, 5 Medium. RISC-V maps Small→medlow, Medium→medany,
 *   Large→medlarge — bare-metal images above 2 GiB need Medium.
 * @returns Target-machine handle to release with Dispose.
 */
pub method(Target) CreateTargetMachineEx(
  triple: string,
  cpu: string,
  features: string,
  opt_level: int32,
  {code_model: int32 = 0, relocation: int32 = 0, abi: string = ""}
) -> TargetMachine;

/**
 * @brief `LLVMDisposeTargetMachine`. Do not `nyra_free`.
 */
pub method(TargetMachine) Dispose() -> void;

/**
 * @brief `LLVMCreateTargetDataLayout`; caller must `TargetData.Dispose`.
 * @returns Target-layout handle to release with Dispose.
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
 * @returns Data-layout string (`LLVMCopyStringRepOfTargetData`); owns the Nyra copy.
 */
pub method(TargetData) LayoutString() -> string;

/**
 * @brief Query the target ABI allocation size of a borrowed LLVM type handle.
 * @returns Allocation size in bytes under this target data layout.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) ABISizeOfHandle(type_handle: *mut void) -> uint64;

/**
 * @brief Query the target ABI alignment of a borrowed LLVM type handle.
 * @returns Required ABI alignment in bytes.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) ABIAlignmentOfHandle(type_handle: *mut void) -> uint32;

/**
 * @brief Query a struct element offset under this target data layout.
 * @returns Byte offset of the zero-based element index.
 * @note The LLVM type handle is borrowed and must remain valid for the query; element queries
 *   require a valid struct index.
 */
pub method(TargetData) OffsetOfElementHandle(type_handle: *mut void, index: uint32) -> uint64;
