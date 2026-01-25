// Copyright 2023–2025 Skip
// SPDX-License-Identifier: MIT

import Foundation
import SkipUI

public struct PhaseAnimator<Phase, Content>: View where Phase: Equatable, Content: View {
    private let phases: [Phase]
    private let trigger: AnyHashable?
    private let content: (Phase) -> Content
    private let animation: (Phase) -> SkipUI.Animation?
    
    public init(
        _ phases: [Phase],
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> SkipUI.Animation? = { _ in .default }
    ) {
        self.phases = phases
        self.trigger = nil
        self.content = content
        self.animation = animation
    }
    
    public init<Trigger: Equatable & Hashable>(
        _ phases: [Phase],
        trigger: Trigger,
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> SkipUI.Animation? = { _ in .default }
    ) {
        self.phases = phases
        self.trigger = AnyHashable(trigger)
        self.content = content
        self.animation = animation
    }
    
    public var body: some View {
        self
    }
}

extension PhaseAnimator: SkipUIBridging {
    // Bridge support - PhaseAnimator bridging has actor isolation challenges
    nonisolated public var Java_view: any SkipUI.View {
        // For now, return a placeholder due to bridging complexity
        // PhaseAnimator would need special handling for trigger and closure bridging
        return SkipUI.EmptyView()
    }
}