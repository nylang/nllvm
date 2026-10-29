// Copyright (c) 2026 tangxiangjiang
// SPDX-License-Identifier: MIT

/** @brief Borrowed-call string conversion for LLVM C APIs. */
module LlvmCString;
import "stdlib:stdlib.ny";

/**
 * @brief Heap buffer copy of `s` with trailing NUL for LLVM C `const char*` crossings.
 * @note Nyra `string.data` is length-based and may lack a terminator; passing `.data` alone can
 *   poison ModuleID / source_filename / symbol names with heap garbage.
 * @note Caller must keep the returned buffer alive for the duration of the C API call (LLVM
 *   copies ModuleID / symbol names / paths during the call).
 */
// Own a terminating-NUL copy for the duration of the foreign LLVM call; Nyra string storage is not assumed terminated.
/**
 * @brief Copy a length-based Nyra string into temporary NUL-terminated LLVM call storage.
 * @returns An owned byte array; retain it through the foreign call and let language drop
 *   release it.
 */
pub func LlvmCStringBuffer(s: string) -> owned <int8>[] {
  let n: int32 = s.length;
  var buf: owned <int8>[] = new <int8>[n + 1];
  unsafe {
    var i: int32 = 0;
    let base: intptr = s.data as intptr;
    while i < n {
      if base != (0 as intptr) {
        let src: *const int8 = (base + (i as intptr)) as *const int8;
        buf[i] = *src;
      } else {
        buf[i] = 0i8;
      }

      i = i + 1;
    }

    buf[n] = 0i8;
  }

  return buf;
}
