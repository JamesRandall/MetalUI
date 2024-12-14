//
//  Button.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//

import Metal
import Combine

public struct Button : View, HasChildren, HasStateTriggeredContent, HasViewProperties {
    internal let children : [any View]
    internal let hoverContent : [any View]
    internal let touchedContent : [any View]
    var action : () -> ()
    
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public init(action: @escaping () -> (), @ViewBuilder content: () -> [any View]) {
        self.action = action
        self.children = content()
        self.hoverContent = []
        self.touchedContent = []
    }
    
    internal init(
        properties: ViewProperties,
        action: @escaping () -> (),
        builtContent: [any View],
        buildHoverContent: [any View],
        buildTouchedContent: [any View]) {
        self.properties = properties
        self.children = builtContent
        self.action = action
        self.hoverContent = buildHoverContent
        self.touchedContent = buildTouchedContent
    }
    
    public var body : some View { self }
    public var hoverBody: some View { self }
    public var touchedBody: some View { self }
}

