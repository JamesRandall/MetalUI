//
//  GuiInstanceData.swift
//  MetalUI
//
//  Created by James Randall on 07/12/2024.
//

import simd

struct GuiInstanceData {
    var color: simd_float4
    var position: simd_float2
    var size: simd_float2
    var texTopLeft: simd_float2
    var texBottomRight: simd_float2
    var textureIndex: simd_int1
    var shouldTexture: simd_int1
    var isVisible: simd_int1
    
    static let zero = GuiInstanceData(color: .zero, position: .zero, size: .zero, texTopLeft: .zero, texBottomRight: .zero, textureIndex: 0, shouldTexture: 0, isVisible: 1)
}
