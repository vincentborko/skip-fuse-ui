// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest
import SkipSwiftUI
import SkipTest

final class PresentationTests : XCTestCase {
    
    func testPresentationDetents() {
        // Test single detent
        let view1 = Text("Test")
            .presentationDetents([.medium])
        XCTAssertNotNil(view1)
        
        // Test multiple detents
        let view2 = Text("Test")
            .presentationDetents([.medium, .large])
        XCTAssertNotNil(view2)
        
        // Test custom height detent
        let view3 = Text("Test")
            .presentationDetents([.height(300)])
        XCTAssertNotNil(view3)
        
        // Test fraction detent
        let view4 = Text("Test")
            .presentationDetents([.fraction(0.7)])
        XCTAssertNotNil(view4)
    }
    
    func testPresentationDragIndicator() {
        // Test visible drag indicator
        let view1 = Text("Test")
            .presentationDragIndicator(.visible)
        XCTAssertNotNil(view1)
        
        // Test hidden drag indicator
        let view2 = Text("Test")
            .presentationDragIndicator(.hidden)
        XCTAssertNotNil(view2)
        
        // Test automatic drag indicator
        let view3 = Text("Test")
            .presentationDragIndicator(.automatic)
        XCTAssertNotNil(view3)
    }
    
    func testPresentationCornerRadius() {
        // Test custom corner radius
        let view1 = Text("Test")
            .presentationCornerRadius(20.0)
        XCTAssertNotNil(view1)
        
        // Test nil corner radius (default)
        let view2 = Text("Test")
            .presentationCornerRadius(nil)
        XCTAssertNotNil(view2)
        
        // Test zero corner radius
        let view3 = Text("Test")
            .presentationCornerRadius(0.0)
        XCTAssertNotNil(view3)
    }
    
    func testPresentationBackgroundInteraction() {
        // Test automatic interaction
        let view1 = Text("Test")
            .presentationBackgroundInteraction(.automatic)
        XCTAssertNotNil(view1)
        
        // Test enabled interaction
        let view2 = Text("Test")
            .presentationBackgroundInteraction(.enabled)
        XCTAssertNotNil(view2)
        
        // Test disabled interaction
        let view3 = Text("Test")
            .presentationBackgroundInteraction(.disabled)
        XCTAssertNotNil(view3)
        
        // Test enabled up through medium detent
        let view4 = Text("Test")
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        XCTAssertNotNil(view4)
    }
    
    func testPresentationCompactAdaptation() {
        // Test automatic adaptation
        let view1 = Text("Test")
            .presentationCompactAdaptation(.automatic)
        XCTAssertNotNil(view1)
        
        // Test no adaptation
        let view2 = Text("Test")
            .presentationCompactAdaptation(.none)
        XCTAssertNotNil(view2)
        
        // Test sheet adaptation
        let view3 = Text("Test")
            .presentationCompactAdaptation(.sheet)
        XCTAssertNotNil(view3)
        
        // Test popover adaptation
        let view4 = Text("Test")
            .presentationCompactAdaptation(.popover)
        XCTAssertNotNil(view4)
        
        // Test fullScreenCover adaptation
        let view5 = Text("Test")
            .presentationCompactAdaptation(.fullScreenCover)
        XCTAssertNotNil(view5)
        
        // Test horizontal and vertical adaptation
        let view6 = Text("Test")
            .presentationCompactAdaptation(horizontal: .sheet, vertical: .fullScreenCover)
        XCTAssertNotNil(view6)
    }
    
    func testCombinedPresentationModifiers() {
        // Test combining multiple presentation modifiers
        let view = Text("Test")
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(16.0)
            .presentationBackgroundInteraction(.enabled)
            .presentationCompactAdaptation(.sheet)
        
        XCTAssertNotNil(view)
    }
    
    func testPresentationDetentValues() {
        // Test PresentationDetent creation
        let medium = PresentationDetent.medium
        let large = PresentationDetent.large
        let height = PresentationDetent.height(250.0)
        let fraction = PresentationDetent.fraction(0.5)
        
        XCTAssertNotNil(medium)
        XCTAssertNotNil(large)
        XCTAssertNotNil(height)
        XCTAssertNotNil(fraction)
    }
    
    func testPresentationBackgroundInteractionValues() {
        // Test PresentationBackgroundInteraction values
        let automatic = PresentationBackgroundInteraction.automatic
        let enabled = PresentationBackgroundInteraction.enabled
        let disabled = PresentationBackgroundInteraction.disabled
        let enabledUpThrough = PresentationBackgroundInteraction.enabled(upThrough: .medium)
        
        XCTAssertNotNil(automatic)
        XCTAssertNotNil(enabled)
        XCTAssertNotNil(disabled)
        XCTAssertNotNil(enabledUpThrough)
    }
    
    func testPresentationAdaptationValues() {
        // Test PresentationAdaptation values
        let automatic = PresentationAdaptation.automatic
        let none = PresentationAdaptation.none
        let popover = PresentationAdaptation.popover
        let sheet = PresentationAdaptation.sheet
        let fullScreenCover = PresentationAdaptation.fullScreenCover
        
        XCTAssertNotNil(automatic)
        XCTAssertNotNil(none)
        XCTAssertNotNil(popover)
        XCTAssertNotNil(sheet)
        XCTAssertNotNil(fullScreenCover)
    }
}