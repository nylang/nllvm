# Source provenance

Extracted with `git subtree split --prefix=source/llvm` from NyraLang
revision `697ee111dbde913641adcaffe31bc1107bd52254`. The extracted history ends
at `0f37de844af1a4f5eaaa0da6e577b493fb565e4e` before the independent-package migration commit.

The source manifest currently targets a NyraLang workspace checkout at
`third_party/nllvm`, with SDK source dependencies under `../../source/`.
The public repository is <https://github.com/nylang/nllvm>. The relative dependency
paths remain a workspace development arrangement. Package versions are preserved
during extraction. The LLVM toolchain is distributed separately from these
bindings.
