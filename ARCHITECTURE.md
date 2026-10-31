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
- `private/debug_info.ny` defines `DebugInfo`, the native debug-state owner.
  It creates function/local metadata, finalizes it and explicitly disposes its
  DIBuilder. Metadata references are named inline fields, with no Nyra heap
  slot allocation or pointer-stride layout assumptions. Copy is deleted; moving
  transfers the native resource and clears the source. Default and disposed values are inert; repeated
  disposal is safe. Borrowed LLVM context/module/builder handles must outlive use.
- `private/llvm_c.ni` is the internal foreign ABI contract; it is not exported.
  Call-local C strings use stdlib `string.ToCStringBytes`, retained through the
  foreign call. There is no package-local duplicate C-string allocator.

Each implementation imports the reference model and explicit faces; no wrapper
shares another wrapper's private mutable state. LLVM's established reference
lifetimes and explicit Dispose contracts are unchanged. The contract-test TU
imports the implementations independently; it is not a part of the context TU.

## Compiler emitter provider operations

`interface/provider.ni` exposes `DwarfBuilder` and the additional typed handle
operations implemented in `private/provider.ny`. The compiler has no duplicate
LLVM foreign declarations. Context/Module/Value/Builder retain their existing
handle contracts; DwarfBuilder owns recursive-composite bookkeeping for one
native debug operation. C entry points remain in private/llvm_c.ni.

## 1.0.5 source migration

`Target.InitializeAll` and `Target.DefaultTriple` replace free entry points.
`DebugInfo.New` and instance operations replace the untyped integer debug API.
The new debug handle must not be copied while live. This preserves the package's
existing explicit LLVM resource policy; it adds no product heap/free API.
The native C ABI is unchanged. All source consumers must rebuild against matching
1.0.5 stdlib source (`ToCStringBytes` and integer formatting). The focused
parent receipt is `docs/roadmaps/m_v1.0.5/nllvm-owner-refactor.json` and passes
eight package tests, including inert and live debug-resource behavior. This
source migration is not a published package version or SDK qualification.

## Provider ownership follow-up

The former empty `LlvmNative` namespace is removed.
Its debug-builder operations have moved to a concrete `DwarfBuilder` retaining
one DIBuilder reference and its pending recursive-composite records. Context,
Module, Value and Builder operations move to their existing typed handles.
DwarfBuilder finalization/disposal remains explicit and ordered before module
or context disposal, as in the existing LLVM handle contract. Pending bookkeeping
is owned by the builder value and discarded on failure/drop; no mutable pending
list is passed through the compiler/provider boundary. Moving a live value
transfers that bookkeeping; callers must not copy it. Core emission owns the
builder for one emission operation. C provider symbols and metadata framing stay
unchanged. The parent `docs/roadmaps/m_v1.0.5/nllvm-provider-owner-refactor.json` records ten
package units, backend safety/handle checks, 22 face checks and a native compiler
source build on macOS arm64. The package has zero coding findings. Final SDK
qualification and independent publication remain separate.
