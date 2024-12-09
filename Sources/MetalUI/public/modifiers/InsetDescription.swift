//
//  InsetDescription.swift
//  MetalUI
//
//  Created by James Randall on 09/12/2024.
//

@MainActor
struct InsetDescription {
    var border: [Border]
    var width : Float
    
    public static let none = InsetDescription(border: [.all], width: 0.0)
}
