// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0

public enum ControlSize : CaseIterable, Comparable, Hashable, Sendable {
    case mini
    case small
    case regular
    case large
    case extraLarge

    /// Ordinal index used to bridge this size to SkipUI's `Int`-backed `ControlSize`.
    /// The case order here matches SkipUI's enum, so the index equals SkipUI's `rawValue`.
    var bridgedValue: Int {
        return ControlSize.allCases.firstIndex(of: self) ?? 2 // .regular
    }
}
