// Copyright 2023–2025 Skip
// SPDX-License-Identifier: MIT

import Foundation
import SkipUI

// Use SkipUI's protocols
public typealias Animatable = SkipUI.Animatable
public typealias Keyframes = SkipUI.Keyframes
public typealias KeyframeTrackContent = SkipUI.KeyframeTrackContent

public struct KeyframeAnimator<Value, KeyframePath, Content>: View, SkipUIBridging
    where Value: Animatable, KeyframePath: Keyframes, Content: View {
    
    private let initialValue: Value
    private let trigger: AnyHashable?
    private let content: (Value) -> Content
    private let keyframes: () -> KeyframePath
    
    public init(
        initialValue: Value,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        self.initialValue = initialValue
        self.trigger = nil
        self.content = content
        self.keyframes = keyframes
    }
    
    public init<Trigger: Equatable>(
        initialValue: Value,
        trigger: Trigger,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        self.initialValue = initialValue
        self.trigger = AnyHashable(trigger)
        self.content = content
        self.keyframes = keyframes
    }
    
    public var body: some View {
        self
    }
}


    // Bridge support
    nonisolated public var Java_view: any SkipUI.View {
        if let trigger = trigger {
            return SkipUI.KeyframeAnimator(
                initialValue: initialValue,
                trigger: trigger,
                content: { value in
                    content(value).Java_viewOrEmpty
                },
                keyframes: keyframes
            )
        } else {
            return SkipUI.KeyframeAnimator(
                initialValue: initialValue,
                content: { value in
                    content(value).Java_viewOrEmpty
                },
                keyframes: keyframes
            )
        }
    }
}

// Re-export SkipUI builders
public typealias KeyframesBuilder = SkipUI.KeyframesBuilder
public typealias KeyframeTrackContentBuilder = SkipUI.KeyframeTrackContentBuilder
public typealias KeyframeTrack = SkipUI.KeyframeTrack