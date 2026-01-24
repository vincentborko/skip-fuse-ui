// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import SwiftUI
import XCTest

struct BridgeContentTransitionTestView: View {
    @State var count = 0
    @State var text = "Hello"
    
    var body: some View {
        VStack(spacing: 20) {
            // Test numeric text transition
            Text("\\(count)")
                .contentTransition(.numericText())
                .font(.largeTitle)
                .onTapGesture {
                    withAnimation {
                        count += 1
                    }
                }
            
            // Test opacity transition
            Text(text)
                .contentTransition(.opacity)
                .font(.title)
                .onTapGesture {
                    withAnimation {
                        text = text == "Hello" ? "World" : "Hello"
                    }
                }
            
            // Test interpolate transition
            Text(count % 2 == 0 ? "Even" : "Odd")
                .contentTransition(.interpolate)
                .font(.headline)
            
            // Test identity transition
            Text("No Animation")
                .contentTransition(.identity)
                .font(.caption)
        }
        .padding()
    }
}

final class ContentTransitionTests: XCTestCase {
    
    func testContentTransitionBridge() throws {
        // Test that the ContentTransition bridge works
        let identity = ContentTransition.identity
        let opacity = ContentTransition.opacity
        let interpolate = ContentTransition.interpolate
        let numericText = ContentTransition.numericText()
        let numericTextCountdown = ContentTransition.numericText(countsDown: true)
        
        // Verify they have the expected raw values
        XCTAssertEqual(identity.rawValue, 0)
        XCTAssertEqual(opacity.rawValue, 1)
        XCTAssertEqual(interpolate.rawValue, 2)
        XCTAssertEqual(numericText.rawValue, 3)
        XCTAssertEqual(numericTextCountdown.rawValue, 3)
        
        // Test that they're equatable
        XCTAssertEqual(identity, ContentTransition.identity)
        XCTAssertNotEqual(identity, opacity)
        
        // Test that numericText variants are equal
        XCTAssertEqual(numericText, numericTextCountdown)
    }
    
    func testContentTransitionModifier() throws {
        let view = Text("Test")
        
        // These should compile without errors - testing the bridge
        _ = view.contentTransition(.identity)
        _ = view.contentTransition(.opacity)
        _ = view.contentTransition(.interpolate)
        _ = view.contentTransition(.numericText())
        _ = view.contentTransition(.numericText(countsDown: true))
        _ = view.contentTransition(.numericText(value: 42))
    }
    
    func testBridgeContentTransitionView() throws {
        // Test that the view compiles and can be created
        let view = BridgeContentTransitionTestView()
        XCTAssertNotNil(view)
    }
}