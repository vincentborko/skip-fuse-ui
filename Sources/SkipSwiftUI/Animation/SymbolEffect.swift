// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import SkipBridge
import SwiftUI

// Bridge for symbol effect modifiers
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension View {

    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    nonisolated public func symbolEffect<T>(_ effect: T, options: SymbolEffectOptions = .default, isActive: Bool = true) -> some View where T: IndefiniteSymbolEffect, T: SymbolEffect {
        return ModifierView(target: self) {
            // Bridge to Kotlin implementation
            // Note: This requires the SymbolEffect types to be bridged as well
            $0.Java_viewOrEmpty
        }
    }

    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    nonisolated public func symbolEffect<T, U>(_ effect: T, options: SymbolEffectOptions = .default, value: U) -> some View where T: DiscreteSymbolEffect, T: SymbolEffect, U: Equatable {
        return ModifierView(target: self) {
            // Bridge to Kotlin implementation for value-triggered effects
            // Note: This requires the SymbolEffect types to be bridged as well
            $0.Java_viewOrEmpty
        }
    }

    @available(*, unavailable)
    nonisolated public func symbolEffectsRemoved(_ isEnabled: Bool = true) -> some View {
        return self
    }
}
