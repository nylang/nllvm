// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief Opaque LLVM reference value layouts shared by typed wrappers. */
module LlvmHandles;
import "stdlib:stdlib.ny";

/**
 * @brief Opaque wrapper: `handle` holds `LLVMContextRef` as `*mut void`.
 */
pub struct Context {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTypeRef` as `*mut void`.
 */
pub struct Type {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMValueRef` as `*mut void`.
 */
pub struct Value {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMBasicBlockRef` as `*mut void`.
 */
pub struct BasicBlock {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMModuleRef` as `*mut void`.
 */
pub struct Module {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMBuilderRef` as `*mut void`.
 */
pub struct Builder {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetRef` as `*mut void`.
 */
pub struct Target {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetMachineRef` as `*mut void`.
 */
pub struct TargetMachine {
  handle: *mut void;
}

/**
 * @brief Opaque wrapper: `handle` holds `LLVMTargetDataRef` as `*mut void`.
 */
pub struct TargetData {
  handle: *mut void;
}
