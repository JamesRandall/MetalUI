//
//  Button.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//

import Metal
import Combine

public struct Button : View, HasChildren, HasStateTriggeredContent, InteractivityStateBasedView, HasViewProperties {
    internal let children : [any View]
    internal let hoverChildren : [any View]
    internal let pressedChildren : [any View]
    var action : () -> ()
    
    var properties: ViewProperties = ViewProperties.getDefault()
    var stateTrackingId : UUID = UUID()
    
    public init(action: @escaping () -> (), @ViewBuilder content: () -> [any View]) {
        self.action = action
        self.children = content()
        self.hoverChildren = []
        self.pressedChildren = []
    }
    
    internal init(
        properties: ViewProperties,
        stateTrackingId: UUID,
        action: @escaping () -> (),
        builtContent: [any View],
        buildHoverContent: [any View],
        buildPressedContent: [any View]) {
            self.properties = properties
            self.children = builtContent
            self.action = action
            self.hoverChildren = buildHoverContent
            self.pressedChildren = buildPressedContent
            self.stateTrackingId = stateTrackingId
    }
    
    public var body : some View { self }
}

