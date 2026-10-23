/**
 * @brief Package-local smoke: LLVMContextCreate / Dispose via Context wrappers.
 * @note Requires Go driver ExtraArgs from in-repo `LLVM_PREFIX` (m_v0.7_p5).
 */

part of Llvm;

@test
func test_llvm_context_create_dispose() {
  let ctx: Context = Context.Create();
  AssertTrue(ctx.handle != (0 as *mut void));
  ctx.Dispose();
}
