//
//  GuiViewBuilderBase.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd
import CoreGraphics

internal class GuiViewBuilderBase {
    let worldProjection : float4x4
    var layoutStack: [PropagatingRenderProperties]
    let boundsSize : simd_float2
    let textManager : TextManager
    
    init (worldProjection: float4x4, size: simd_float2, textManager: TextManager) {
        self.worldProjection = worldProjection
        
        layoutStack = [.zero]
        self.boundsSize = size
        self.textManager = textManager
    }
    
    internal func rectangleInstanceData(position: simd_float2, size: simd_float2, color: simd_float4) -> GuiInstanceData {
        GuiInstanceData(color: color, position: position, size: size, texTopLeft: .zero, texBottomRight: .zero, shouldTexture: .zero)
    }
    
    internal func textInstanceData(text: String, position: simd_float2, color: simd_float4, fontName: String, fontSize: Float) -> GuiInstanceData {
        guard let textRenderInfo = self.textManager.getRenderInfo(text: text, fontName: fontName, color: color, size: CGFloat(fontSize)) else {
            return GuiInstanceData.zero
        }
        
        return GuiInstanceData(
            color:.zero,
            position: position,
            size: textRenderInfo.rect.size.toSimd(),
            texTopLeft: self.textManager.texTopLeft(textRenderInfo), //simd_float2(0,0),
            texBottomRight: self.textManager.texBottomRight(textRenderInfo), // simd_float2(1,1),
            shouldTexture: 1
        )
    }
    
    func getPropagatingProperties() -> PropagatingRenderProperties {
        layoutStack.last!
    }
    
    func getPropagatingPropertiesStackSize() -> Int { layoutStack.count }
    
    func pushPropagatingProperty(position:simd_float2) {
        let tipLayout = getPropagatingProperties()
        layoutStack.append(tipLayout.with(position: tipLayout.position + position))
    }
    
    func resetForChild() {
        let tipLayout = getPropagatingProperties()
        layoutStack.append(
            PropagatingRenderProperties(
                position: tipLayout.position,
                autoSizeMode: .toParent)
        )
    }
    
    func popPropagatingProperty() {
        layoutStack.removeLast()
    }
}
