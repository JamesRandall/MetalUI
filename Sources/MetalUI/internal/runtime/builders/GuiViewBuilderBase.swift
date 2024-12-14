//
//  GuiViewBuilderBase.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd
import CoreGraphics

@MainActor
internal class GuiViewBuilderBase {
    let worldProjection : float4x4
    private var layoutStack: [PropagatingRenderProperties]
    let boundsSize : simd_float2
    let textManager : TextManager
    
    init (worldProjection: float4x4, size: simd_float2, textManager: TextManager) {
        self.worldProjection = worldProjection
        
        layoutStack = [.zero]
        self.boundsSize = size
        self.textManager = textManager
    }
    
    internal func rectangleInstanceData(position: simd_float2, size: simd_float2, color: simd_float4) -> GuiInstanceData {
        GuiInstanceData(color: color, position: position, size: size, texTopLeft: .zero, texBottomRight: .zero, shouldTexture: .zero, isVisible: self.getPropagatingProperties().visible ? 1 : 0)
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
            shouldTexture: 1,
            isVisible: self.getPropagatingProperties().visible ? 1 : 0
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
    
    func pushPropagatingProperty(visibility:Bool) {
        let tipLayout = getPropagatingProperties()
        layoutStack.append(tipLayout.with(visibility: visibility))
    }
    
    func resetForChild() {
        let tipLayout = getPropagatingProperties()
        layoutStack.append(
            PropagatingRenderProperties(
                position: tipLayout.position,
                autoSizeMode: .toParent,
                visible: tipLayout.visible)
        )
    }
    
    func popPropagatingProperty() {
        layoutStack.removeLast()
    }
    
    private func getActualStateForView(_ view : any HasStateTriggeredChildren) -> InteractivityState {
        // we need to get this through an interaction tracker
        .pressed
    }
    
    func getStateFor(view : any HasStateTriggeredChildren) -> InteractivityState {
        // we only allow a state to be returned for a state that has an associated view - otherwise we return
        // the default set of children
        let actualState = getActualStateForView(view)
        let children = getChildrenForState(view, with: actualState)
        if children.isEmpty { return .normal }
        return actualState
    }
    
    func getChildrenForState(_ view : any HasStateTriggeredChildren) -> [any View] {
        let actualState = getStateFor(view: view)
        switch actualState {
        case .hover: return view.hoverChildren
        case .normal: return view.children
        case .pressed: return view.pressedChildren
        }
    }
    
    private func getChildrenForState(_ view : any HasStateTriggeredChildren, with: InteractivityState) -> [any View] {
        switch with {
        case .hover: return view.hoverChildren
        case .normal: return view.children
        case .pressed: return view.pressedChildren
        }
    }
}
