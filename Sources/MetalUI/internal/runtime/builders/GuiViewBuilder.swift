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
    func getLayout() -> RenderLayout
    func getLayoutStackSize() -> Int
    func pushLayout(position:simd_float2)
    func pushLayout(size:simd_float2)
    func pushAutoSizeIfRequired(requestedSize: simd_float2)
    func pushLayout(autoSizeMode: AutoSizeMode)
    func resetForChild()
    func popLayout()
    
    func getRenderProperties() -> RenderProperties
    func setRenderProperties(_ renderProperties: RenderProperties)
    func mergeProperty(backgroundColor: simd_float4)
    func mergeProperty(foregroundColor: simd_float4)
    func mergeProperty(border: BorderDescription)
    
    func fillRectangle(position:simd_float2, size: simd_float2, color: simd_float4)
    func fillRectangle()
    func border(position: simd_float2, size: simd_float2, description: BorderProperty)
    func border()
    func text(text: String)
    func getSize(text: String) -> simd_float2
}

protocol GuiViewBuilder : GuiMutater {
    
}
