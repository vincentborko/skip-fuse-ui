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
    // Bridge support
    nonisolated public var Java_view: any SkipUI.View {
        // PhaseAnimator is not yet available in skip-ui, so return a placeholder
        return SkipUI.EmptyView()
        
        // TODO: Uncomment when PhaseAnimator is available in skip-ui
        /*
        if let trigger = trigger {
            return SkipUI.PhaseAnimator(phases, trigger: trigger, content: { phase in
                content(phase).Java_viewOrEmpty
            }, animation: animation)
        } else {
            return SkipUI.PhaseAnimator(phases, content: { phase in
                content(phase).Java_viewOrEmpty
            }, animation: animation)
        }
        */
    }
}