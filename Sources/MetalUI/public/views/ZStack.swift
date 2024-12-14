//
//  Panel.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import Combine

public struct ZStack : View, HasChildren, HasViewProperties {
    internal let children : [any View]
    
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public init(@ViewBuilder content: () -> [any View]) {
        self.children = content()
    }
    
    internal init(properties: ViewProperties, builtContent: [any View]) {
        self.properties = properties
        self.children = builtContent
    }
    
    public var body : some View { self }
}

