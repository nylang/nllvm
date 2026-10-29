// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

module LlvmBasicBlock;
import "stdlib:stdlib.ny";
import "public/handles.ny";
import "private/llvm_c.ni";
import "interface/basic_block.ni";

/**
 * @brief Open layout for `BasicBlock` (LLVMBasicBlockRef wrapper).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

/**
 * @brief Whether this block already ends in a terminator instruction.
 * @returns Whether this block already ends in a terminator instruction.
 */
pub method(BasicBlock) HasTerminator() -> bool {
  return LLVMGetBasicBlockTerminator(self.handle) != (0 as *mut void);
}
