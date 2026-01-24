// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import XCTest
#if !SKIP
@testable import SkipSwiftUI
#endif

final class SkipSwiftUITests: XCTestCase {
    func testSkipUI() throws {
        XCTAssertEqual(3, 1 + 2)
    }
    
    #if !SKIP
    func testSafeAreaInsetAPIs() throws {
        // Test that safe area inset APIs compile and return views
        struct TestView: View {
            var body: some View {
                ScrollView {
                    ForEach(0..<10, id: \.self) { index in
                        Text("Item \(index)")
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Button("Action") { }
                        Spacer()
                        Button("Delete") { }
                    }
                    .padding()
                    .background(.bar)
                }
                .safeAreaInset(edge: .top, alignment: .trailing, spacing: 8) {
                    Text("Notification")
                        .padding()
                        .background(.yellow)
                }
                .safeAreaInset(edge: .leading, alignment: .center) {
                    VStack {
                        Button("1") { }
                        Button("2") { }
                    }
                    .padding()
                }
                .safeAreaInset(edge: .trailing, spacing: 16) {
                    Text("Side")
                        .rotationEffect(.degrees(-90))
                        .padding()
                }
            }
        }
        
        // Test compilation
        let _ = TestView()
        
        // Test multiple insets work together
        let view = Color.blue
            .safeAreaInset(edge: .bottom) { Color.red }
            .safeAreaInset(edge: .top) { Color.green }
        
        let _ = view
        
        XCTAssertTrue(true, "Safe area inset APIs compile successfully")
    }
    #endif
}
