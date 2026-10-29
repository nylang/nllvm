# nllvm module architecture

The public entry exports the same typed LLVM faces and reference value layouts.
It assembles closed implementations without exporting native C declarations.

- `public/handles.ny` owns the existing opaque-reference value layouts. It holds
  reference values only; it does not initialize LLVM or orchestrate compilation.
- `private/context.ny` owns context allocation, context-local types and constants.
- `private/type.ny`, `value.ny` and `basic_block.ny` implement their respective
  typed operations. They borrow LLVM references and preserve the existing ABI.
- `private/module.ny` owns LLVM module operations and pass execution.
- `private/builder.ny` owns instruction construction and insertion position.
- `private/target.ny` owns target initialization, target machines and data layouts.
- `private/debug_info.ny` owns debug metadata construction and finalization.
- `private/llvm_c.ni` is the internal foreign ABI contract. `private/c_string.ny`
  owns temporary NUL-terminated call storage. Neither is barrel-exported.

Each implementation imports the reference model and explicit faces; no wrapper
shares another wrapper's private mutable state. LLVM's established reference
lifetimes and explicit Dispose contracts are unchanged. The contract-test TU
imports the implementations independently; it is not a part of the context TU.

## Compiler emitter provider operations

`interface/provider.ni` and `private/provider.ny` add the `LlvmNative` provider
namespace used by the compiler for missing low-level debug/constant operations.
Foreign declarations remain centralized in `private/llvm_c.ni`; the compiler
contains no duplicated LLVM foreign declarations.

Pending recursive debug composite records belong to the caller's emission
session, passed explicitly as an opaque head pointer. Begin/member/end mutate
only that head. Discard frees pending bookkeeping on failure and never accesses
a destroyed builder/context. There is no process-global pending composite list.
Existing typed reference/resource contracts are retained. The internal bridge
and caller must be rebuilt together; these additive source changes have no new
execution receipt while parent P3 qualification is paused.
