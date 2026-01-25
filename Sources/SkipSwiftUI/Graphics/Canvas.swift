// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE

// Canvas is not currently bridgeable from Swift to Kotlin due to the closure-based drawing model
// and the mutable GraphicsContext parameter. These would need to be reimplemented in Swift.
// For now, Canvas views must be implemented directly in skip-ui.

#endif