// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SkipUI

/// Symbol variants that can be applied to SF Symbols.
/// Uses a bit flag internally to combine variants.
public struct SymbolVariants : RawRepresentable, Hashable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // Bit flags for each variant type (must match skip-ui)
    private static let fillBit = 1 << 0      // 1
    private static let circleBit = 1 << 1    // 2
    private static let squareBit = 1 << 2    // 4
    private static let rectangleBit = 1 << 3 // 8
    private static let slashBit = 1 << 4     // 16

    public static let none = SymbolVariants(rawValue: 0)
    public static let fill = SymbolVariants(rawValue: fillBit)
    public static let circle = SymbolVariants(rawValue: circleBit)
    public static let square = SymbolVariants(rawValue: squareBit)
    public static let rectangle = SymbolVariants(rawValue: rectangleBit)
    public static let slash = SymbolVariants(rawValue: slashBit)

    /// Combine with fill variant
    public var fill: SymbolVariants {
        return SymbolVariants(rawValue: rawValue | Self.fillBit)
    }

    /// Combine with circle variant
    public var circle: SymbolVariants {
        return SymbolVariants(rawValue: rawValue | Self.circleBit)
    }

    /// Combine with square variant
    public var square: SymbolVariants {
        return SymbolVariants(rawValue: rawValue | Self.squareBit)
    }

    /// Combine with rectangle variant
    public var rectangle: SymbolVariants {
        return SymbolVariants(rawValue: rawValue | Self.rectangleBit)
    }

    /// Combine with slash variant
    public var slash: SymbolVariants {
        return SymbolVariants(rawValue: rawValue | Self.slashBit)
    }

    /// Check if this variant contains another variant
    public func contains(_ other: SymbolVariants) -> Bool {
        return (rawValue & other.rawValue) == other.rawValue
    }
}

public enum SymbolRenderingMode : Int, Sendable {
    case monochrome = 0
    case multicolor = 1
    case hierarchical = 2
    case palette = 3
}

public struct SymbolVariableValueMode : Equatable, Sendable {
    public static let color = SymbolVariableValueMode()
    public static let draw = SymbolVariableValueMode()
}

public struct SymbolColorRenderingMode : Equatable, Sendable {
    public static let flat = SymbolColorRenderingMode()
    public static let gradient = SymbolColorRenderingMode()
}

// MARK: - SymbolEffect

// SwiftUI's symbol-effect surface, modeled here so the app's `.symbolEffect(.pulse, …)` / `.symbolEffect(.bounce, value:)`
// call sites compile on the Skip path. SF Symbols render on Android as a single Material `ImageVector` (no per-layer
// access), so the bridge supports the whole-glyph transform/opacity effects — `.pulse`, `.bounce`, `.scale` — which map
// cleanly onto a Compose `graphicsLayer` animation in skip-ui. Layer-walking effects (`.variableColor`) and
// content-transition effects (`.replace`/`.appear`/`.disappear`) are accepted for source-compat but fall through to no
// animation (see the discriminator below).

public protocol SymbolEffect {}
public protocol IndefiniteSymbolEffect {}
public protocol DiscreteSymbolEffect {}
public protocol TransitionSymbolEffect {}
public protocol ContentTransitionSymbolEffect {}

/// Options controlling how a symbol effect plays (repeat / speed). Accepted for source compatibility;
/// the Android bridge currently ignores them (the effect plays at its default cadence).
public struct SymbolEffectOptions : Sendable {
    public init() {}
    public static var `default`: SymbolEffectOptions { SymbolEffectOptions() }
    public static var repeating: SymbolEffectOptions { SymbolEffectOptions() }
    public static var nonRepeating: SymbolEffectOptions { SymbolEffectOptions() }
    public static func `repeat`(_ count: Int) -> SymbolEffectOptions { SymbolEffectOptions() }
    public static func speed(_ speed: Double) -> SymbolEffectOptions { SymbolEffectOptions() }
    public func `repeat`(_ count: Int) -> SymbolEffectOptions { self }
    public func speed(_ speed: Double) -> SymbolEffectOptions { self }
}

public struct PulseSymbolEffect : SymbolEffect, IndefiniteSymbolEffect, DiscreteSymbolEffect, Sendable {
    public init() {}
    public var wholeSymbol: PulseSymbolEffect { self }
    public var byLayer: PulseSymbolEffect { self }
}

public struct BounceSymbolEffect : SymbolEffect, DiscreteSymbolEffect, Sendable {
    let isDown: Bool
    public init() { self.isDown = false }
    init(isDown: Bool) { self.isDown = isDown }
    public var up: BounceSymbolEffect { BounceSymbolEffect(isDown: false) }
    public var down: BounceSymbolEffect { BounceSymbolEffect(isDown: true) }
    public var wholeSymbol: BounceSymbolEffect { self }
    public var byLayer: BounceSymbolEffect { self }
}

public struct ScaleSymbolEffect : SymbolEffect, IndefiniteSymbolEffect, Sendable {
    let isDown: Bool
    public init() { self.isDown = false }
    init(isDown: Bool) { self.isDown = isDown }
    public var up: ScaleSymbolEffect { ScaleSymbolEffect(isDown: false) }
    public var down: ScaleSymbolEffect { ScaleSymbolEffect(isDown: true) }
    public var wholeSymbol: ScaleSymbolEffect { self }
    public var byLayer: ScaleSymbolEffect { self }
}

extension SymbolEffect where Self == PulseSymbolEffect {
    public static var pulse: PulseSymbolEffect { PulseSymbolEffect() }
}

extension SymbolEffect where Self == BounceSymbolEffect {
    public static var bounce: BounceSymbolEffect { BounceSymbolEffect() }
}

extension SymbolEffect where Self == ScaleSymbolEffect {
    public static var scale: ScaleSymbolEffect { ScaleSymbolEffect() }
}

/// Discriminate the opaque effect value into the (effect, direction) integers the skip-ui bridge understands.
/// effect: 0 = none/unsupported, 1 = pulse, 2 = bounce, 3 = scale. direction: 0 = up/default, 1 = down.
private func bridgedSymbolEffect(_ effect: Any) -> (effect: Int, direction: Int) {
    if effect is PulseSymbolEffect { return (1, 0) }
    if let bounce = effect as? BounceSymbolEffect { return (2, bounce.isDown ? 1 : 0) }
    if let scale = effect as? ScaleSymbolEffect { return (3, scale.isDown ? 1 : 0) }
    return (0, 0)
}

extension View {
    nonisolated public func symbolEffect<T>(_ effect: T, options: SymbolEffectOptions = .default, isActive: Bool = true) -> some View where T : IndefiniteSymbolEffect, T : SymbolEffect {
        let bridged = bridgedSymbolEffect(effect)
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.symbolEffect(bridgedEffect: bridged.effect, direction: bridged.direction, isActive: isActive, bridgedValue: 0)
        }
    }

    nonisolated public func symbolEffect<T, U>(_ effect: T, options: SymbolEffectOptions = .default, value: U) -> some View where T : DiscreteSymbolEffect, T : SymbolEffect, U : Equatable {
        let bridged = bridgedSymbolEffect(effect)
        // The bridge can't carry an arbitrary Equatable, so we send a stable per-process change token:
        // any change in `value` changes the token, which re-triggers the discrete animation in skip-ui.
        let token = String(describing: value).hashValue & 0x7FFFFFFF
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.symbolEffect(bridgedEffect: bridged.effect, direction: bridged.direction, isActive: true, bridgedValue: token)
        }
    }

    @available(*, unavailable)
    nonisolated public func symbolRenderingMode(_ mode: SymbolRenderingMode?) -> some View {
        return stubView()
    }

    nonisolated public func symbolVariant(_ variant: SymbolVariants) -> some View {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.symbolVariant(bridgedRawValue: variant.rawValue)
        }
    }

    @available(*, unavailable)
    nonisolated public func symbolVariableValueMode(_ mode: SymbolVariableValueMode?) -> some View {
        stubView()
    }

    @available(*, unavailable)
    nonisolated public func symbolColorRenderingMode(_ mode: SymbolColorRenderingMode?) -> some View {
        stubView()
    }
}

extension Image {
    @available(*, unavailable)
    public func symbolRenderingMode(_ mode: SymbolRenderingMode?) -> Image {
        fatalError()
    }

    @available(*, unavailable)
    public func symbolVariableValueMode(_ mode: SymbolVariableValueMode?) -> Image {
        fatalError()
    }

    @available(*, unavailable)
    public func symbolColorRenderingMode(_ mode: SymbolColorRenderingMode?) -> Image {
        fatalError()
    }
}
