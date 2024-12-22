//
//  GuiViewBuilder.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Metal
import simd

enum InteractivityState {
    case normal, hover, pressed
}

@MainActor
protocol GuiMutater {
    func getPropagatingProperties() -> PropagatingRenderProperties
    func getPropagatingPropertiesStackSize() -> Int
    func pushPropagatingProperty(position:simd_float2)
    func pushPropagatingProperty(visibility:Bool)
    func resetForChild()
    func popPropagatingProperty()
    
    func fillRectangle(with properties: ViewProperties, size: simd_float2)
    func border(with properties: ViewProperties, size: simd_float2)
    func text(text: String, properties: ViewProperties)
    func getSize(text: String, properties: ViewProperties) -> simd_float2
    func image(name: String, imagePack: String, properties: ViewProperties)
    
    func registerInteractiveZone(viewId: UUID, zone: CGRect)
    func getStateFor(view : any InteractivityStateBasedView) -> InteractivityState
    func getChildrenForState(_ view : any InteractivityStateBasedView) -> [any View]
}

protocol GuiViewBuilder : GuiMutater {
    
}
