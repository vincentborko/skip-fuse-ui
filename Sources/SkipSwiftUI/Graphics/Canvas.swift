// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE

import SkipSwiftUI

// MARK: - Canvas Bridge

extension Canvas {
    nonisolated public init(opaque: Bool = false, colorMode: ColorRenderingMode = .nonLinear, rendersAsynchronously: Bool = false, renderer: @escaping (inout GraphicsContext, CGSize) -> Void, @ViewBuilder symbols: () -> Symbols) where Symbols: View {
        return SkipCanvasView(
            opaque: opaque,
            colorMode: colorMode,
            rendersAsynchronously: rendersAsynchronously,
            renderer: renderer,
            symbols: symbols()
        )
    }
}

extension Canvas where Symbols == EmptyView {
    nonisolated public init(opaque: Bool = false, colorMode: ColorRenderingMode = .nonLinear, rendersAsynchronously: Bool = false, renderer: @escaping (inout GraphicsContext, CGSize) -> Void) {
        return SkipCanvasView(
            opaque: opaque,
            colorMode: colorMode,
            rendersAsynchronously: rendersAsynchronously,
            renderer: renderer,
            symbols: EmptyView()
        )
    }
}

/// Internal wrapper that handles bridging to skip-ui Canvas
private struct SkipCanvasView<Symbols: View>: View {
    let opaque: Bool
    let colorMode: ColorRenderingMode
    let rendersAsynchronously: Bool
    let renderer: (inout GraphicsContext, CGSize) -> Void
    let symbols: Symbols
    
    var body: some View {
        ModifierView(target: symbols) {
            $0.Java_viewOrEmpty.Canvas(
                opaque: opaque,
                colorMode: colorMode,
                rendersAsynchronously: rendersAsynchronously,
                renderer: renderer
            )
        }
    }
}

// MARK: - GraphicsContext Bridge

extension GraphicsContext {
    /// Bridge for opacity property
    nonisolated public var opacity: Double {
        get { Java_view.opacity }
        set { Java_view.opacity = newValue }
    }
    
    /// Bridge for blendMode property 
    nonisolated public var blendMode: GraphicsContext.BlendMode {
        get { Java_view.blendMode }
        set { Java_view.blendMode = newValue }
    }
    
    /// Bridge for environment property
    nonisolated public var environment: EnvironmentValues {
        return Java_view.environment
    }
    
    /// Bridge for transform property
    nonisolated public var transform: CGAffineTransform {
        get { Java_view.transform }
        set { Java_view.transform = newValue }
    }
    
    /// Bridge for clipBoundingRect property
    nonisolated public var clipBoundingRect: CGRect {
        return Java_view.clipBoundingRect
    }

    /// Bridge for scaleBy method
    nonisolated public mutating func scaleBy(x: CGFloat, y: CGFloat) {
        Java_view.scaleBy(x: x, y: y)
    }
    
    /// Bridge for translateBy method
    nonisolated public mutating func translateBy(x: CGFloat, y: CGFloat) {
        Java_view.translateBy(x: x, y: y)
    }
    
    /// Bridge for rotate method
    nonisolated public mutating func rotate(by angle: Angle) {
        Java_view.rotate(by: angle)
    }
    
    /// Bridge for concatenate method
    nonisolated public mutating func concatenate(_ matrix: CGAffineTransform) {
        Java_view.concatenate(matrix)
    }

    /// Bridge for clip method
    nonisolated public mutating func clip(to path: Path, style: FillStyle = FillStyle(), options: GraphicsContext.ClipOptions = ClipOptions()) {
        Java_view.clip(to: path, style: style, options: options)
    }
    
    /// Bridge for clipToLayer method
    nonisolated public mutating func clipToLayer(opacity: Double = 1, options: GraphicsContext.ClipOptions = ClipOptions(), content: (inout GraphicsContext) throws -> Void) rethrows {
        try Java_view.clipToLayer(opacity: opacity, options: options, content: content)
    }

    /// Bridge for resolve shading method
    nonisolated public func resolve(_ shading: GraphicsContext.Shading) -> GraphicsContext.Shading {
        return Java_view.resolve(shading)
    }
    
    /// Bridge for drawLayer method
    nonisolated public func drawLayer(content: (inout GraphicsContext) throws -> Void) rethrows {
        try Java_view.drawLayer(content: content)
    }

    /// Bridge for fill method
    nonisolated public func fill(_ path: Path, with shading: GraphicsContext.Shading, style: FillStyle = FillStyle()) {
        Java_view.fill(path, with: shading, style: style)
    }
    
    /// Bridge for stroke methods
    nonisolated public func stroke(_ path: Path, with shading: GraphicsContext.Shading, style: StrokeStyle) {
        Java_view.stroke(path, with: shading, style: style)
    }
    
    nonisolated public func stroke(_ path: Path, with shading: GraphicsContext.Shading, lineWidth: CGFloat = 1) {
        Java_view.stroke(path, with: shading, lineWidth: lineWidth)
    }

    /// Bridge for image methods
    nonisolated public func resolve(_ image: Image) -> GraphicsContext.ResolvedImage {
        return Java_view.resolve(image)
    }
    
    nonisolated public func draw(_ image: GraphicsContext.ResolvedImage, in rect: CGRect, style: FillStyle = FillStyle()) {
        Java_view.draw(image, in: rect, style: style)
    }
    
    nonisolated public func draw(_ image: GraphicsContext.ResolvedImage, at point: CGPoint, anchor: UnitPoint = .center) {
        Java_view.draw(image, at: point, anchor: anchor)
    }
    
    nonisolated public func draw(_ image: Image, in rect: CGRect, style: FillStyle = FillStyle()) {
        Java_view.draw(image, in: rect, style: style)
    }
    
    nonisolated public func draw(_ image: Image, at point: CGPoint, anchor: UnitPoint = .center) {
        Java_view.draw(image, at: point, anchor: anchor)
    }

    /// Bridge for text methods
    nonisolated public func resolve(_ text: Text) -> GraphicsContext.ResolvedText {
        return Java_view.resolve(text)
    }
    
    nonisolated public func draw(_ text: GraphicsContext.ResolvedText, in rect: CGRect) {
        Java_view.draw(text, in: rect)
    }
    
    nonisolated public func draw(_ text: GraphicsContext.ResolvedText, at point: CGPoint, anchor: UnitPoint = .center) {
        Java_view.draw(text, at: point, anchor: anchor)
    }
    
    nonisolated public func draw(_ text: Text, in rect: CGRect) {
        Java_view.draw(text, in: rect)
    }
    
    nonisolated public func draw(_ text: Text, at point: CGPoint, anchor: UnitPoint = .center) {
        Java_view.draw(text, at: point, anchor: anchor)
    }

    /// Bridge for symbol methods
    nonisolated public func resolveSymbol<ID>(id: ID) -> GraphicsContext.ResolvedSymbol? where ID : Hashable {
        return Java_view.resolveSymbol(id: id)
    }
    
    nonisolated public func draw(_ symbol: GraphicsContext.ResolvedSymbol, in rect: CGRect) {
        Java_view.draw(symbol, in: rect)
    }
    
    nonisolated public func draw(_ symbol: GraphicsContext.ResolvedSymbol, at point: CGPoint, anchor: UnitPoint = .center) {
        Java_view.draw(symbol, at: point, anchor: anchor)
    }

    /// Bridge for filter method
    nonisolated public mutating func addFilter(_ filter: GraphicsContext.Filter, options: GraphicsContext.FilterOptions = FilterOptions()) {
        Java_view.addFilter(filter, options: options)
    }
}

// MARK: - ColorRenderingMode Bridge

extension ColorRenderingMode: SkipUIBridging {
    public var Java_view: any View {
        switch self {
        case .nonLinear:
            return EmptyView().tag("nonLinear")
        case .linear:
            return EmptyView().tag("linear") 
        case .extendedLinear:
            return EmptyView().tag("extendedLinear")
        }
    }
}

#endif