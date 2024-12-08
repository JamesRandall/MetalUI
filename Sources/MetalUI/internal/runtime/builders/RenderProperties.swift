//
//  RenderProperties.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd

struct RenderProperties {
    var backgroundColor : simd_float4
    var foregroundColor : simd_float4
    var border: BorderProperty
    
    static let zero = RenderProperties(backgroundColor: .zero, foregroundColor: .one, border: .none)
}
