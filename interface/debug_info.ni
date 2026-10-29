// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief LLVM DWARF builder facade. State is an opaque native handle. */
import "stdlib:stdlib.ny";
import "interface/context.ni";
import "interface/module.ni";
import "interface/value.ni";
import "interface/builder.ni";

/**
 * @brief Create native DWARF builder state for a module and source path.
 * @returns Owned opaque state, or zero if the state allocation fails.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoCreate(ctx: Context, mod: Module, source_path: string, optimized: bool) -> intptr;

/**
 * @brief Attach a source-level function scope and retain it as the current debug scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoAttachFunction(
  state: intptr,
  fn_value: Value,
  name: string,
  line: int32,
  optimized: bool
) -> void;

/**
 * @brief Set builder location within the current debug function scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoSetLocation(state: intptr, builder: Builder, line: int32) -> void;

/**
 * @brief Describe a stack slot as a local or argument in the current debug scope.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoDeclare(
  state: intptr,
  builder: Builder,
  slot: Value,
  name: string,
  typ: string,
  line: int32,
  arg_no: int32
) -> void;

/**
 * @brief Finalize pending DWARF metadata before disposing builder state.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoFinalize(state: intptr) -> void;

/**
 * @brief Dispose the native DIBuilder and free its state; zero is a no-op.
 * @note State is the opaque handle returned by DebugInfoCreate; finalize metadata before
 *   disposal. Context/module lifetimes remain caller-controlled.
 */
pub func DebugInfoDispose(state: intptr) -> void;
