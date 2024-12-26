//
//  Panel.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import Combine

public struct ZStack : View, HasViewProperties {
    internal let content : any View
    internal var children : [any View] {
        if let group = content as? Group {
            return group.children
        }
        return [content]
    }
    
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public init(@ViewBuilder content: () -> any View) {
        self.content = content()
    }
    
    internal init(properties: ViewProperties, builtContent: any View) {
        self.properties = properties
        self.content = builtContent
    }
    
    public var body : some View { self }
}

