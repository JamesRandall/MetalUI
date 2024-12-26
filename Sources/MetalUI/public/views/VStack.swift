//
//  Panel.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import Combine

public struct VStack : View, HasViewProperties, HasChildren {
    internal let content : any View
    internal var children : [any View] {
        if let group = content as? Group {
            return group.children
        }
        return [content]
    }
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public var spacing: Float = 0
    
    public init(spacing: Float, @ViewBuilder content: () -> some View) {
        self.spacing = spacing
        self.content = content()
    }
    
    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
    }
    
    internal init(builtContent: any View, spacing: Float, properties: ViewProperties) {
        self.content = builtContent
        self.properties = properties
        self.spacing = spacing
    }
    
    public var body : some View { self }
    
    // if the view has a dynamic number of render calls (and therefore instances in the GPU pipeline) then
    // it should be returned here. this allows sufficient space to be reserved in the instance buffer for the
    // maximum draw size of the control
    //
    // its also only required if the control mutates - if a control doesn't mutate then by definition it has a
    // fixed number of render calls
    func maxInstances() -> Int? {
        return nil
    }
}

