//
//  Panel.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import Combine

public struct VStack : View, HasChildren {
    internal let children : [any View]
    
    public init(@ViewBuilder content: () -> [any View]) {
        self.children = content()
    }
    
    internal init(builtContent: [any View]) {
        self.children = builtContent
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

