// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import SkipBridge
import SwiftUI

// Bridge for symbol effect modifiers
extension View {
    
    nonisolated public func symbolEffect<T>(_ effect: T, options: SymbolEffectOptions = .default, isActive: Bool = true) -> some View where T: IndefiniteSymbolEffect, T: SymbolEffect {
        return ModifierView(target: self) {
            // Bridge to Kotlin implementation
            // Note: This requires the SymbolEffect types to be bridged as well
            $0.Java_viewOrEmpty
        }
    }
    
    nonisolated public func symbolEffect<T, U>(_ effect: T, options: SymbolEffectOptions = .default, value: U) -> some View where T: DiscreteSymbolEffect, T: SymbolEffect, U: Equatable {
        return ModifierView(target: self) {
            // Bridge to Kotlin implementation for value-triggered effects
            // Note: This requires the SymbolEffect types to be bridged as well
            $0.Java_viewOrEmpty
        }
    }
    
    nonisolated public func symbolEffectsRemoved(_ isEnabled: Bool = true) -> some View {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.symbolEffectsRemoved(isEnabled)
        }
    }
}