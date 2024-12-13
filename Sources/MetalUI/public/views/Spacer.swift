//
//  Spacer.swift
//  MetalUI
//
//  Created by James Randall on 13/12/2024.
//

import Metal
import Combine

public struct Spacer : View, HasViewProperties {
    var properties: ViewProperties = ViewProperties.getDefault()
    
    internal init(properties: ViewProperties) {
        self.properties = properties
    }
    
    // Leaf nodes return self
    public var body : some View { self }
}
