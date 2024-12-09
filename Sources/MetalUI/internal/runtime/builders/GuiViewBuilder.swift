//
//  GuiViewBuilder.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Metal
import simd

@MainActor
protocol GuiMutater {
    func getPropagatingProperties() -> PropagatingRenderProperties
    func getPropagatingPropertiesStackSize() -> Int
    func pushPropagatingProperty(position:simd_float2)
    func resetForChild()
    func popPropagatingProperty()
    
    //func fillRectangle(position:simd_float2, size: simd_float2, color: simd_float4)
    //func border(position: simd_float2, size: simd_float2, description: BorderProperty)
    func fillRectangle(with properties: ViewProperties, size: simd_float2)
    func border(with properties: ViewProperties, size: simd_float2)
    func text(text: String, properties: ViewProperties)
    func getSize(text: String, properties: ViewProperties) -> simd_float2
}

protocol GuiViewBuilder : GuiMutater {
    
}
