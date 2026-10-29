// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief Product face for LLVM `LLVMBasicBlockRef`.
 * @note Blocks die with the Module; do not Dispose them separately.
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */
import "stdlib:stdlib.ny";

/**
 * @brief Opaque wrapper around `LLVMBasicBlockRef` (`*mut void`).
 */
pub struct BasicBlock;

/**
 * @brief Whether this block already ends in a terminator instruction.
 * @returns Whether this block already ends in a terminator instruction.
 */
pub method(BasicBlock) HasTerminator() -> bool;
