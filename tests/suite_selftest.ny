// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief LLVM wrapper contracts exercised across real module boundaries. */
module LlvmTests;
part "context_selftest.ny";
part "builder_selftest.ny";
part "emit_selftest.ny";
import "stdlib:stdlib.ny";
import "interface/builder.ni";
import "ntest:ntest.ny";
import "public/handles.ny";
import "private/context.ny";
import "private/type.ny";
import "private/value.ny";
import "private/basic_block.ny";
import "private/module.ny";
import "private/builder.ny";
import "private/target.ny";
import "private/debug_info.ny";
