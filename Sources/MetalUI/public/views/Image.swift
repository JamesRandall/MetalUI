//
//  Image.swift
//  MetalUI
//
//  Created by James Randall on 22/12/2024.
//

import Metal
import Combine

public struct Image : View, HasViewProperties {
    var name: String
    var imagePack: String
    var properties: ViewProperties = ViewProperties.getDefault()
    
    public init(_ name: String, imagePack: String = "default") {
        self.name = name
        self.imagePack = imagePack
    }
    
    internal init(_ name: String, imagePack:String, properties: ViewProperties) {
        self.name = name
        self.imagePack = imagePack
        self.properties = properties
    }
    
    // Leaf nodes return self
    public var body : some View { self }
}
