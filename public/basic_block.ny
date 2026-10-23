/**
 * @brief Open layout for `BasicBlock` (LLVMBasicBlockRef wrapper).
 * @see docs/design/compiler/nyra-llvm.md §1.5 · m_v0.6_p2 Record
 */

part of Llvm;

/**
 * @brief Opaque wrapper: `handle` holds `LLVMBasicBlockRef` as `*mut void`.
 */
pub struct BasicBlock {
  handle: *mut void;
}

pub method(BasicBlock) HasTerminator() -> bool {
  return LLVMGetBasicBlockTerminator(self.handle) != (0 as *mut void);
}
