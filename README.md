# nllvm

Development API 0.41.0 requires a matching Nyra SDK 1.0.5 or newer.
Rebuild precompiled consumers against the matching interfaces and runtime.

Nyra bindings for the LLVM C API. This package is independently versioned;
it does not contain the upstream LLVM toolchain.

Development version: **0.41.0**. Repository: <https://github.com/nylang/nllvm>.

## Development setup

A standalone checkout uses implicit stdlib/ntest from the installed SDK;
no NyraLang private source directories are required. LLVM libraries and tools
remain separate native prerequisites. Use LLVM 21.1.8 with the matching host SDK.
This repository contains bindings, helper code and tests, not the compiler.
The original v0.40.0 tag retains its historical manifest. Use the immutable
1.0.5-compatible development revision below; no new package tag is claimed.

## Integration

Import `nllvm:nllvm.ny` using a `nllvm` dependency in `package.yaml`.
The C shim under `private/` is linked with the pinned LLVM toolchain by the
Nyra compiler. The development toolchain remains at `third_party/llvm` in
NyraLang.

See [MIGRATION.md](MIGRATION.md) for source history and the current workspace
layout. Run the package suite from NyraLang with
`python3 nyra.py test --package nllvm`. Test data is owned by this repository.

## Portable Git dependency

This working API requires matching Nyra SDK 1.0.5 compiler, runtime and analyzer
capabilities. Its manifest uses implicit SDK packages and contains no paths into
the private compiler checkout. Use the SDK's native `nyra` for Git preparation.
Older source tags retain their documented SDK requirements; they do not qualify
this development API. SDK/package publication remains a separate operation.

Add this dependency to your application's `package.yaml`:

```yaml
dependencies:
  nllvm:
    git: https://github.com/nylang/nllvm.git
    rev: d8b2ae9ef996432316ee90ed01a3a52e93305e15
```

Run `nyra lock ./app` and commit `nyra.lock`; use
`nyra fetch ./app --frozen` to prepare the same graph again. The example pins
an existing public development commit whose API matches this source. It does
not select the older stable `main` or claim a newly published package tag.
Normal compiler and analyzer operations do not fetch dependencies.

For local multi-package development, list package-file pointers in a common
`workspace.yaml`. Workspace replacements keep Git declarations shareable;
origin lock updates deliberately disable replacements. A package entry and its
SDK can move without rewriting publisher paths.

## License

Licensed under the [MIT License](LICENSE).

This license covers the Nyra bindings and helper code in this repository.
LLVM itself retains its upstream Apache License 2.0 with LLVM Exceptions;
its license is supplied with the separate LLVM toolchain.

## Module architecture

See [module responsibilities, ownership and dependency boundaries](ARCHITECTURE.md).

## Coding-rule lint

`package.yaml` selects the portable `lint.yaml` profile. It requires the
1.0.5 P7 analyzer candidate (or a later SDK containing those rules); the
published 1.0.4 analyzer does not implement them. `import: default` inherits
the selected workspace profile when present, otherwise analyzer SDK defaults.
No sibling source path is required. Run `nyra-analyzer lint . --json`. Lint checks
coding rules; runtime qualification is a separate gate.

## 1.0.5 source API migration

Use `Target.InitializeAll()` / `Target.DefaultTriple()` and retain a
`DebugInfo.New(...)` value for its instance operations. Finalize before Dispose;
keep the context/module alive and do not copy a live debug owner. Build all
consumers with matching 1.0.5 stdlib source for `string.ToCStringBytes`.
The old free-function and untyped debug-handle APIs are removed. See
[ownership and module contracts](ARCHITECTURE.md). No tag or release is implied.

The low-level provider API now uses a concrete `DwarfBuilder` for recursive debug
metadata, plus Context/Module/Value/Builder operations. The former empty
`LlvmNative` namespace is removed. DwarfBuilder owns pending bookkeeping; keep
Finalize/Dispose ordered before module/context disposal and do not copy a live
builder. Its move operation transfers the sole pending owner. See ARCHITECTURE
for focused source evidence and the unchanged C provider boundary.
