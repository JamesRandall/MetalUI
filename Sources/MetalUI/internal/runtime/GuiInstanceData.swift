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
    var shouldTexture: simd_int1
}
