// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0

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
    nonisolated public func safeAreaInset<V>(edge: VerticalEdge, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> V) -> some View where V : View {
        let content = content()
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.safeAreaInset(bridgedEdge: Int(edge.rawValue), isVertical: true, alignmentKey: alignment.key, spacing: spacing, bridgedContent: content.Java_viewOrEmpty)
        }
    }

    nonisolated public func safeAreaInset<V>(edge: HorizontalEdge, alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> V) -> some View where V : View {
        let content = content()
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.safeAreaInset(bridgedEdge: Int(edge.rawValue), isVertical: false, alignmentKey: alignment.key, spacing: spacing, bridgedContent: content.Java_viewOrEmpty)
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
