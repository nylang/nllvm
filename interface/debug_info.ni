// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief LLVM DWARF builder facade. State is an opaque native handle. */
import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/module.ni";
import "interface/value.ni";
import "interface/builder.ni";

/**
 * @brief LLVM DWARF builder state with explicit native resource lifetime.
 * @note Finalize before Dispose, then release the borrowed module/context. A disposed
 *       value is inert. As with other LLVM handles, do not copy a live owner.
 */
pub struct DebugInfo;

/**
 * @brief Create native DWARF builder state for a module and source path.
 * @returns A live debug handle, or an inert handle if native state allocation fails.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub static method(DebugInfo) New(ctx: Context, mod: Module, source_path: string, optimized: bool) -> DebugInfo;

/**
 * @brief Attach a source-level function scope and retain it as the current debug scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) AttachFunction(
  fn_value: Value,
  name: string,
  line: int32,
  optimized: bool
) -> void;

/**
 * @brief Set builder location within the current debug function scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) SetLocation(builder: Builder, line: int32) -> void;

/**
 * @brief Describe a stack slot as a local or argument in the current debug scope.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Declare(
  builder: Builder,
  slot: Value,
  name: string,
  typ: string,
  line: int32,
  arg_no: int32
) -> void;

/**
 * @brief Finalize pending DWARF metadata before disposing builder state.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Finalize() -> void;

/**
 * @brief Dispose the native DIBuilder and clear inline metadata; zero is a no-op.
 * @note The handle retains native DIBuilder state; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub method(DebugInfo) Dispose() -> void;

/** @brief Whether this handle retains native debug-builder state.
 * @returns False for default, allocation-failure or disposed state. */
pub method(DebugInfo) IsValid() -> bool;

/** @brief Transfer the native builder and borrowed metadata handles.
 * @returns Sole owning value; the moved-from value is inert. */
pub method(DebugInfo) operator move() -> DebugInfo;

/** @brief Copying would duplicate native DIBuilder disposal ownership.
 * @returns Deleted operation; move a live owner instead. */
pub method(DebugInfo) operator copy() -> DebugInfo = delete;
