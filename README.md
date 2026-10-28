# nllvm

Nyra bindings for the LLVM C API. This package is independently versioned;
it does not contain the upstream LLVM toolchain.

Version: **0.40.0**. Repository: <https://github.com/nylang/nllvm>.

## Development setup

A standalone checkout uses implicit stdlib/ntest from the installed SDK;
no NyraLang private source directories are required. LLVM libraries and tools
remain separate native prerequisites. Use LLVM 21.1.8 with the matching host SDK.
This repository contains bindings, helper code and tests, not the compiler.
The original v0.40.0 tag retains its historical manifest; use the current main
commit for portable dependencies and lock the resolved Git revision.

## Integration

Import `nllvm:nllvm.ny` using a `nllvm` dependency in `package.yaml`.
The C shim under `private/` is linked with the pinned LLVM toolchain by the
Nyra compiler. The development toolchain remains at `third_party/llvm` in
NyraLang.

See [MIGRATION.md](MIGRATION.md) for source history and the current workspace
layout. Run the package suite from NyraLang with
`python3 nyra.py test --package nllvm`. Test data is owned by this repository.

## Portable Git dependency

Source imports use the installed SDK's implicit runtime packages (SDK 1.0.2 or
later); package manifests contain no paths into the private compiler checkout.
For automatic Git preparation use native `nyra` 1.0.3 or later. That manager's
public SDK publication is separate from this package; SDK 1.0.2 does not ship it.
With SDK 1.0.2, a manual clone and explicit local consumer path remain usable.

Add this dependency to your application's `package.yaml`:

```yaml
dependencies:
  nllvm:
    git: https://github.com/nylang/nllvm.git
    rev: main
```

Then run `nyra lock ./app` and commit `nyra.lock`; use
`nyra fetch ./app --frozen` to prepare the pinned graph again. `main` above is
an initial selector; the lock fixes the exact commit/content. Normal compiler
and analyzer operations do not fetch dependencies. Historical tags are immutable
and may retain older workspace-specific manifests.

For local multi-package development, list package-file pointers in a common
`workspace.yaml`. Workspace replacements keep Git declarations shareable;
origin lock updates deliberately disable replacements. A package entry and its
SDK can move without rewriting publisher paths.

## License

Licensed under the [MIT License](LICENSE).

This license covers the Nyra bindings and helper code in this repository.
LLVM itself retains its upstream Apache License 2.0 with LLVM Exceptions;
its license is supplied with the separate LLVM toolchain.
