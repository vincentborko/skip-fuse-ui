// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

@frozen public struct SafeAreaRegions : OptionSet, BitwiseCopyable, Sendable {
    public let rawValue: UInt

    @inlinable public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let container = SafeAreaRegions(rawValue: 1 << 0)

    public static let keyboard = SafeAreaRegions(rawValue: 1 << 1)

    public static let all: SafeAreaRegions = [.container, .keyboard]
}

extension View {
    /* @inlinable */ nonisolated public func safeAreaInset<V>(edge: VerticalEdge, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> V) -> some View where V : View {
        let bridgedContent = content()
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.safeAreaInset(
                edge: SkipUI.VerticalEdge(rawValue: edge.rawValue) ?? .bottom, 
                alignment: SkipUI.HorizontalAlignment(key: alignment.key), 
                spacing: spacing, 
                content: { bridgedContent.Java_viewOrEmpty }
            )
        }
    }

    /* @inlinable */ nonisolated public func safeAreaInset<V>(edge: HorizontalEdge, alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> V) -> some View where V : View {
        let bridgedContent = content()
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.safeAreaInset(
                edge: SkipUI.HorizontalEdge(rawValue: edge.rawValue) ?? .leading,
                alignment: SkipUI.VerticalAlignment(key: alignment.key),
                spacing: spacing,
                content: { bridgedContent.Java_viewOrEmpty }
            )
        }
    }

    @available(*, unavailable)
    nonisolated public func safeAreaPadding(_ insets: EdgeInsets) -> some View {
        return self
    }

    @available(*, unavailable)
    nonisolated public func safeAreaPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    nonisolated public func safeAreaPadding(_ length: CGFloat) -> some View {
        return self
    }
}
