//
//  GuiViewBuilderBase.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd
import CoreGraphics
import Foundation

@MainActor
internal class GuiViewBuilderBase {
    let worldProjection : float4x4
    private var layoutStack: [PropagatingRenderProperties]
    let boundsSize : simd_float2
    let textManager : TextManager
    let stateTracker : StateTracker
    let imageManager : ImageManager
    
    init (worldProjection: float4x4, size: simd_float2, imageManager: ImageManager, textManager: TextManager, stateTracker: StateTracker) {
        self.worldProjection = worldProjection
        
        layoutStack = [.zero]
        self.boundsSize = size
        self.imageManager = imageManager
        self.textManager = textManager
        self.stateTracker = stateTracker
    }
    
    internal func rectangleInstanceData(position: simd_float2, size: simd_float2, color: simd_float4) -> GuiInstanceData {
        GuiInstanceData(
            color: color,
            position: position,
            size: size,
            texTopLeft: .zero,
            texBottomRight: .zero,
            textureIndex: 0,
            shouldTexture: .zero,
            isVisible: self.getPropagatingProperties().visible ? 1 : 0)
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
            texBottomRight: self.textManager.texBottomRight(textRenderInfo),
            textureIndex: 0, // simd_float2(1,1),
            shouldTexture: 1,
            isVisible: self.getPropagatingProperties().visible ? 1 : 0
        )
    }
    
    internal func imageInstanceData(name: String, imagePackName: String, position: simd_float2, size: simd_float2) -> GuiInstanceData? {
        guard let (subImage,textureSlot) = self.imageManager.getSubImage(name: name, imagePackName: imagePackName) else { return nil }
        
        return GuiInstanceData(
            color:.zero,
            position: position,
            size: size,
            texTopLeft: simd_float2(Float(subImage.u), Float(subImage.v)),
            texBottomRight: simd_float2(Float(subImage.u2), Float(subImage.v2)),
            textureIndex: simd_int1(textureSlot),
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
    
    func registerInteractiveZone(viewId: UUID, zone: CGRect) {
        //print("registering interactive zone \(viewId)")
        self.stateTracker.registerInteractiveZone(viewId: viewId, zone: zone)
    }
    
    private func getActualStateForView(_ view : any InteractivityStateBasedView) -> InteractivityState {
        //print("checking state for \(view.stateTrackingId)")
        let response = stateTracker.isInteractiveZoneHit(viewId: view.stateTrackingId)
        if response.isHit {
            return response.mouseDown ? InteractivityState.pressed : InteractivityState.hover
        }
        // we need to get this through an interaction tracker
        return InteractivityState.normal
    }
    
    func getStateFor(view : any InteractivityStateBasedView) -> InteractivityState {
        // we only allow a state to be returned for a state that has an associated view - otherwise we return
        // the default set of children
        let actualState = getActualStateForView(view)
        let children = getChildrenForState(view, with: actualState)
        if children.isEmpty { return .normal }
        return actualState
    }
    
    func getChildrenForState(_ view : any InteractivityStateBasedView) -> [any View] {
        let actualState = getStateFor(view: view)
        switch actualState {
        case .hover: return view.hoverChildren
        case .normal: return view.children
        case .pressed: return view.pressedChildren
        }
    }
    
    private func getChildrenForState(_ view : any InteractivityStateBasedView, with: InteractivityState) -> [any View] {
        switch with {
        case .hover: return view.hoverChildren
        case .normal: return view.children
        case .pressed: return view.pressedChildren
        }
    }
}
