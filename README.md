# nllvm

Nyra bindings for the LLVM C API. This package is independently versioned;
it does not contain the upstream LLVM toolchain.

Import `nllvm:nllvm.ny` using a `nllvm` dependency in `package.yaml`.
The C shim under `private/` is linked with the pinned LLVM toolchain by the
Nyra compiler. The development toolchain remains at `third_party/llvm` in
NyraLang.

See [MIGRATION.md](MIGRATION.md) for source history and the current workspace
layout. Run the package suite from NyraLang with
`python3 nyra.py test --package nllvm`. Test data is owned by this repository.
