# nllvm

Nyra bindings for the LLVM C API. This package is independently versioned;
it does not contain the upstream LLVM toolchain.

Version: **0.40.0**. Repository: <https://github.com/nylang/nllvm>.

## Development setup

This source release uses the NyraLang workspace layout: check out this package
at `third_party/nllvm`, with `source/stdlib` and `source/ntest` in the workspace.
The relative dependency paths in `package.yaml` target that layout. A standalone
clone does not include those dependencies, a Nyra compiler, or LLVM libraries.
Use the workspace's pinned LLVM 21.1.8 toolchain for this release.

This repository contains the bindings, helper code, and package tests; it does
not contain the Nyra compiler implementation. Publishing the repository does
not enable automatic remote dependency resolution.

## Integration

Import `nllvm:nllvm.ny` using a `nllvm` dependency in `package.yaml`.
The C shim under `private/` is linked with the pinned LLVM toolchain by the
Nyra compiler. The development toolchain remains at `third_party/llvm` in
NyraLang.

See [MIGRATION.md](MIGRATION.md) for source history and the current workspace
layout. Run the package suite from NyraLang with
`python3 nyra.py test --package nllvm`. Test data is owned by this repository.

## License

Licensed under the [MIT License](LICENSE).

This license covers the Nyra bindings and helper code in this repository.
LLVM itself retains its upstream Apache License 2.0 with LLVM Exceptions;
its license is supplied with the separate LLVM toolchain.
