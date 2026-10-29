// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/**
 * @brief Sole public entry for package `nllvm` — LLVM-C wrappers for self-host codegen.
 * @note External importers use `import "nllvm:nllvm.ny";` only. Import `stdlib:stdlib.ny` only
 *   (no source/stdlib/private).
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
export "interface/debug_info.ni";
export "public/handles.ny";

import "interface/context.ni";
import "interface/type.ni";
import "interface/value.ni";
import "interface/basic_block.ni";
import "interface/module.ni";
import "interface/builder.ni";
import "interface/target.ni";
import "interface/debug_info.ni";
import "private/context.ny";
import "private/type.ny";
import "private/value.ny";
import "private/basic_block.ny";
import "private/module.ny";
import "private/builder.ny";
import "private/target.ny";
import "private/debug_info.ny";

export "interface/provider.ni";
import "interface/provider.ni";
import "private/provider.ny";
