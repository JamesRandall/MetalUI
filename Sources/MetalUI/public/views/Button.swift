//
//  Button.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//

import Metal
import Combine

public struct Button : View, HasStateTriggeredContent, InteractivityStateBasedView, HasViewProperties {
    internal let content : any View
    internal let hoverContent : (any View)?
    internal let pressedContent : (any View)?
    
    var action : () -> ()
    
    var properties: ViewProperties = ViewProperties.getDefault()
    var stateTrackingId : UUID = UUID()
    
    public init(action: @escaping () -> (), @ViewBuilder content: () -> some View) {
        self.action = action
        self.content = content()
        self.hoverContent = nil
        self.pressedContent = nil
    }
    
    internal init(
        properties: ViewProperties,
        stateTrackingId: UUID,
        action: @escaping () -> (),
        builtContent: some View,
        buildHoverContent: (any View)?,
        buildPressedContent: (any View)?) {
            self.properties = properties
            self.content = builtContent
            self.action = action
            self.hoverContent = buildHoverContent
            self.pressedContent = buildPressedContent
            self.stateTrackingId = stateTrackingId
    }
    
    public var body : some View { self }
}

