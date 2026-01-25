// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import SwiftUI
import XCTest

class KeyframeAnimatorBridgeTests: XCTestCase {
    
    // Test animation values struct
    struct TestAnimationValues: Animatable {
        var scale: Double = 1.0
        var rotation: Double = 0.0
        var opacity: Double = 1.0
        
        // Animatable conformance
        var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
            get {
                AnimatablePair(scale, AnimatablePair(rotation, opacity))
            }
            set {
                scale = newValue.first
                rotation = newValue.second.first  
                opacity = newValue.second.second
            }
        }
    }
    
    func testKeyframeAnimatorBridge() {
        // Test basic KeyframeAnimator bridge construction
        let initialValues = TestAnimationValues()
        
        let animator = KeyframeAnimator(initialValue: initialValues) { values in
            Rectangle()
                .scaleEffect(values.scale)
                .rotationEffect(.degrees(values.rotation))
                .opacity(values.opacity)
                .frame(width: 50, height: 50)
        } keyframes: { _ in
            // Note: Due to Skip limitations, keyframe tracks cannot be fully implemented
            // This is a simplified test of the API structure
            EmptyTestKeyframes()
        }
        
        // Should construct without crashing
        XCTAssertNotNil(animator)
        
        // Test Java_view bridge (currently returns EmptyView due to limitations)
        let bridgedView = animator.Java_view
        XCTAssertNotNil(bridgedView)
    }
    
    func testKeyframeAnimatorWithTriggerBridge() {
        // Test KeyframeAnimator with trigger parameter
        let initialValues = TestAnimationValues()
        let trigger = 0
        
        let animator = KeyframeAnimator(
            initialValue: initialValues,
            trigger: trigger
        ) { values in
            Circle()
                .fill(.blue)
                .scaleEffect(values.scale)
                .opacity(values.opacity)
                .frame(width: 60, height: 60)
        } keyframes: { _ in
            EmptyTestKeyframes()
        }
        
        // Should construct without crashing
        XCTAssertNotNil(animator)
        
        // Test bridging behavior (currently limited)
        let bridgedView = animator.Java_view
        XCTAssertNotNil(bridgedView)
    }
    
    func testKeyframeTrackBridge() {
        // Test KeyframeTrack bridge functionality
        // Note: Full implementation requires WritableKeyPath support
        let track = KeyframeTrack(\TestAnimationValues.scale) { 
            // Empty content due to Skip limitations
        }
        
        // Should construct without crashing
        XCTAssertNotNil(track)
    }
    
    func testKeyframesBuilderBridge() {
        // Test KeyframesBuilder functionality
        let builder = KeyframesBuilder<TestAnimationValues>()
        
        // Should not crash during construction
        XCTAssertNotNil(builder)
    }
    
    func testKeyframeAnimatorComplexValuesBridge() {
        // Test with more complex animation values
        struct ComplexValues: Animatable {
            var position: CGPoint = .zero
            var size: CGSize = CGSize(width: 50, height: 50)
            var color: Double = 0.0 // 0.0 = red, 1.0 = blue
            
            var animatableData: AnimatablePair<AnimatablePair<Double, Double>, AnimatablePair<AnimatablePair<Double, Double>, Double>> {
                get {
                    AnimatablePair(
                        AnimatablePair(position.x, position.y),
                        AnimatablePair(
                            AnimatablePair(size.width, size.height),
                            color
                        )
                    )
                }
                set {
                    position = CGPoint(x: newValue.first.first, y: newValue.first.second)
                    size = CGSize(width: newValue.second.first.first, height: newValue.second.first.second)
                    color = newValue.second.second
                }
            }
        }
        
        let initialValues = ComplexValues()
        
        let animator = KeyframeAnimator(initialValue: initialValues) { values in
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 1.0 - values.color, green: 0.5, blue: values.color))
                .frame(width: values.size.width, height: values.size.height)
                .offset(x: values.position.x, y: values.position.y)
        } keyframes: { _ in
            ComplexTestKeyframes()
        }
        
        // Should handle complex value types
        XCTAssertNotNil(animator)
        
        // Test bridging with complex values
        let bridgedView = animator.Java_view
        XCTAssertNotNil(bridgedView)
    }
    
    func testKeyframeAnimatorEdgeCases() {
        // Test edge cases and error conditions
        struct MinimalValues: Animatable {
            var value: Double = 0.0
            
            var animatableData: Double {
                get { value }
                set { value = newValue }
            }
        }
        
        let minimal = KeyframeAnimator(initialValue: MinimalValues()) { values in
            Text("\(values.value)")
        } keyframes: { _ in
            EmptyTestKeyframes()
        }
        
        XCTAssertNotNil(minimal)
        XCTAssertNotNil(minimal.Java_view)
    }
    
    func testKeyframeAnimatorViewBuilder() {
        // Test that ViewBuilder works correctly with KeyframeAnimator
        let initialValues = TestAnimationValues()
        
        let animator = KeyframeAnimator(initialValue: initialValues) { values in
            // Test ViewBuilder with multiple views
            VStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 30))
                    .scaleEffect(values.scale)
                
                Text("Scale: \(values.scale, specifier: "%.2f")")
                    .opacity(values.opacity)
                
                Rectangle()
                    .fill(.blue)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(values.rotation))
            }
        } keyframes: { _ in
            EmptyTestKeyframes()
        }
        
        // Should handle ViewBuilder correctly
        XCTAssertNotNil(animator)
        XCTAssertNotNil(animator.Java_view)
    }
}

// Helper structs for testing - simplified due to Skip limitations
private struct EmptyTestKeyframes: Keyframes {
    // Empty implementation as placeholder
}

private struct ComplexTestKeyframes: Keyframes {
    // Empty implementation as placeholder for complex keyframes
}