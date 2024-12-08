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
    var layoutStack: [RenderLayout]
    var _currentProperties : RenderProperties
    let boundsSize : simd_float2
    let textManager : TextManager
    
    init (worldProjection: float4x4, size: simd_float2, textManager: TextManager) {
        self.worldProjection = worldProjection
        layoutStack = [RenderLayout(position: .zero, size: nil, parentSize: size, autoSizeMode: .toParent)]
        _currentProperties = .zero
        self.boundsSize = size
        self.textManager = textManager
    }
    
    internal func rectangleInstanceData(position: simd_float2, size: simd_float2, color: simd_float4) -> GuiInstanceData {
        GuiInstanceData(color: color, position: position, size: size, texTopLeft: .zero, texBottomRight: .zero, shouldTexture: .zero)
    }
    
    internal func textInstanceData(text: String, position: simd_float2, color: simd_float4, fontSize: CGFloat = 22.0) -> GuiInstanceData {
        guard let textRenderInfo = self.textManager.getRenderInfo(text: text, fontName: "System", color: color, size: fontSize) else {
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
    
    func getLayout() -> RenderLayout {
        layoutStack.last!
    }
    
    func getLayoutStackSize() -> Int { layoutStack.count }
    
    func pushAutoSizeIfRequired(requestedSize: simd_float2) {
        let tipLayout = getLayout()
        if tipLayout.size == nil {
            let newLayout = RenderLayout(position: tipLayout.position, size: tipLayout.autoSizeMode == .toParent ? tipLayout.parentSize : requestedSize, parentSize: tipLayout.parentSize, autoSizeMode: tipLayout.autoSizeMode)
            layoutStack.append(newLayout)
        }
    }
    
    func pushLayout(autoSizeMode: AutoSizeMode) {
        let tipLayout = getLayout()
        layoutStack.append(tipLayout.withAutoSizeMode(autoSizeMode: autoSizeMode))
    }
    
    func pushLayout(position:simd_float2) {
        let tipLayout = getLayout()
        layoutStack.append(tipLayout.withPosition(position: tipLayout.position + position))
    }
    
    func pushLayout(size:simd_float2) {
        let tipLayout = getLayout()
        let newLayout = tipLayout.withSize(size: size)
        layoutStack.append(newLayout)
    }
    
    func getRenderProperties() -> RenderProperties { self._currentProperties }
    
    func setRenderProperties(_ renderProperties: RenderProperties) { self._currentProperties = renderProperties }
    
    func mergeProperty(backgroundColor:simd_float4) {
        self._currentProperties.backgroundColor = backgroundColor
    }
    
    func mergeProperty(foregroundColor:simd_float4) {
        self._currentProperties.foregroundColor = foregroundColor
    }
    
    @MainActor func mergeProperty(border: BorderDescription) {
        let c = border.color
        let w = border.width
        
        border.border.forEach({ side in
            if side == .all {
                self._currentProperties.border = BorderProperty(topColor: c, topWidth: w, leftColor: c, leftWidth: w, rightColor: c, rightWidth: w, bottomColor: c, bottomWidth: w)
            }
            else {
                switch side {
                case .bottom:
                    self._currentProperties.border.bottomColor = c
                    self._currentProperties.border.bottomWidth = w
                case .top:
                    self._currentProperties.border.topColor = c
                    self._currentProperties.border.topWidth = w
                case .left:
                    self._currentProperties.border.leftColor = c
                    self._currentProperties.border.leftWidth = w
                case .right:
                    self._currentProperties.border.rightColor = c
                    self._currentProperties.border.rightWidth = w
                default: ()
                }
            }
        })
    }
    
    func resetForChild() {
        let tipLayout = getLayout()
        layoutStack.append(RenderLayout(position: tipLayout.position, size: nil, parentSize: tipLayout.size ?? tipLayout.parentSize, autoSizeMode: .toParent))
        _currentProperties = .zero
    }
    
    func popLayout() {
        layoutStack.removeLast()
    }
}
