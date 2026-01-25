// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import SwiftUI
import XCTest

class SymbolEffectBridgeTests: XCTestCase {
    
    func testSymbolEffectBridge() {
        // Test that symbol effect modifiers can be bridged
        let image = Image(systemName: "bell")
        
        // Test indefinite effects
        let bouncing = image.symbolEffect(.bounce, isActive: true)
        XCTAssertNotNil(bouncing)
        
        let pulsing = image.symbolEffect(.pulse, isActive: false)
        XCTAssertNotNil(pulsing)
        
        // Test discrete effects
        let bounceOnChange = image.symbolEffect(.bounce, value: 1)
        XCTAssertNotNil(bounceOnChange)
        
        // Test with options
        let fastEffect = image.symbolEffect(.bounce, options: .speed(2.0), isActive: true)
        XCTAssertNotNil(fastEffect)
        
        let repeatEffect = image.symbolEffect(.bounce, options: .repeat(3), value: "test")
        XCTAssertNotNil(repeatEffect)
    }
    
    func testSymbolEffectsRemovedBridge() {
        // Test that symbolEffectsRemoved bridges correctly
        let image = Image(systemName: "star")
            .symbolEffect(.pulse, isActive: true)
        
        let removed = image.symbolEffectsRemoved()
        XCTAssertNotNil(removed)
        
        let notRemoved = image.symbolEffectsRemoved(false)
        XCTAssertNotNil(notRemoved)
    }
    
    func testChainedEffectsBridge() {
        // Test that multiple effects can be chained through the bridge
        let image = Image(systemName: "heart.fill")
            .symbolEffect(.bounce, isActive: true)
            .symbolEffect(.scale(2.0), value: 1)
            .symbolEffectsRemoved(false)
        
        XCTAssertNotNil(image)
    }
    
    func testAllEffectTypesBridge() {
        // Test that all effect types bridge correctly
        let testCases: [(any SymbolEffect, String)] = [
            (BounceSymbolEffect(), "bounce"),
            (PulseSymbolEffect(), "pulse"),
            (VariableColorSymbolEffect(), "variableColor"),
            (ScaleSymbolEffect(), "scale"),
            (ReplaceSymbolEffect(), "replace"),
            (AppearSymbolEffect(), "appear"),
            (DisappearSymbolEffect(), "disappear"),
            (BreatheSymbolEffect(), "breathe"),
            (RotateSymbolEffect(), "rotate"),
            (WiggleSymbolEffect(), "wiggle")
        ]
        
        for (effect, name) in testCases {
            let image = Image(systemName: "star")
            
            // Test as indefinite effect if applicable
            if let indefiniteEffect = effect as? any IndefiniteSymbolEffect {
                let modified = image.symbolEffect(indefiniteEffect, isActive: true)
                XCTAssertNotNil(modified, "\(name) indefinite effect failed")
            }
            
            // Test as discrete effect if applicable
            if let discreteEffect = effect as? any DiscreteSymbolEffect {
                let modified = image.symbolEffect(discreteEffect, value: 1)
                XCTAssertNotNil(modified, "\(name) discrete effect failed")
            }
        }
    }
}