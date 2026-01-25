// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

/// An indication of whether the view associated with this environment allows user interaction.
public enum EditMode : Hashable {
    case inactive
    case transient
    case active

    /// A Boolean value that indicates whether the mode is active.
    public var isEditing: Bool {
        return self != .inactive
    }
}

/// A button that toggles the editing state for the current edit scope.
@available(*, unavailable, message: "EditButton not available in Skip")
public struct EditButton: View {
    public init() {
    }
    
    public var body: some View {
        stubView()
    }
}