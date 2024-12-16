//
//  Text.swift
//  MetalUI
//
//  Created by James Randall on 09/12/2024.
//

import Metal
import Combine

public struct Text : View, HasViewProperties {
    var content: String
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public init(_ content: String) {
        self.content = content
    }
    
    internal init(_ content: String, properties: ViewProperties) {
        self.content = content
        self.properties = properties
    }
    
    // Leaf nodes return self
    public var body : some View { self }
}
