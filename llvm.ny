/**
 * @brief Sole public entry for package `llvm` — LLVM-C wrappers for self-host codegen.
 * @note External importers use `import "llvm:llvm.ny";` only. Import `stdlib:stdlib.ny` only (no source/stdlib/private).
 * @note ADR 0013 — product `export` is interface + public; `import` private for ObjectUnit link.
 * @see docs/design/compiler/nyra-llvm.md
 */

export "interface/context.ni";
export "interface/type.ni";
export "interface/value.ni";
export "interface/basic_block.ni";
export "interface/module.ni";
export "interface/builder.ni";
export "interface/target.ni";
export "public/context.ny";

import "interface/context.ni";
import "interface/type.ni";
import "interface/value.ni";
import "interface/basic_block.ni";
import "interface/module.ni";
import "interface/builder.ni";
import "interface/target.ni";
import "public/context.ny";
