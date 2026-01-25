// Copyright 2023–2025 Skip
// SPDX-License-Identifier: MIT

import Foundation
import SkipUI

// Keyframe types are not available from SkipUI for bridging, define placeholders
public struct LinearKeyframe<Value>: KeyframeTrackContent where Value: Animatable {
    public init(_ value: Value, duration: Double) {
        // Placeholder implementation
    }
}

public struct CubicKeyframe<Value>: KeyframeTrackContent where Value: Animatable {
    public init(_ value: Value, duration: Double) {
        // Placeholder implementation
    }
}

public struct SpringKeyframe<Value>: KeyframeTrackContent where Value: Animatable {
    public init(_ value: Value, duration: Double) {
        // Placeholder implementation
    }
}

public struct MoveKeyframe: KeyframeTrackContent {
    public init() {
        // Placeholder implementation
    }
}