//
//  BorderProperty.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd

struct BorderProperty {
    var topColor: simd_float4
    var topWidth: Float
    var leftColor: simd_float4
    var leftWidth: Float
    var rightColor: simd_float4
    var rightWidth: Float
    var bottomColor: simd_float4
    var bottomWidth: Float
    
    // we default to it being transparent but always draw it - this means we don't have to mess around with the instance data on a bordered
    // element
    static let none = BorderProperty(topColor: .zero, topWidth: 1.0, leftColor: .zero, leftWidth: 1.0, rightColor: .zero, rightWidth: 1.0, bottomColor: .zero, bottomWidth: 1.0)
}
