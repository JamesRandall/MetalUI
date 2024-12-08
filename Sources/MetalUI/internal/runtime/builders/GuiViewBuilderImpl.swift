//
//  GuiMetalBuilder.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Metal
import simd

internal class GuiViewBuilderImpl : GuiViewBuilderBase, GuiViewBuilder {
    private var _instanceData : [GuiInstanceData] = []
    
    var instanceData: [GuiInstanceData] { _instanceData }
    
    func fillRectangle(position: simd_float2, size: simd_float2, color: simd_float4) {
        let rectangleInstanceData = self.rectangleInstanceData(position: position, size: size, color: color)
        self._instanceData.append(rectangleInstanceData)
    }
    
    func fillRectangle() {
        guard let layout = self.layoutStack.last else { return }
        guard let size = layout.size else { return }
        self.fillRectangle(position: layout.position, size: size, color: self.getRenderProperties().backgroundColor)
    }
    
    func border(position: simd_float2, size: simd_float2, description: BorderProperty) {
        if description.leftColor.z == 0.0 { return }
        
        let left = position.x// - size.x / 2.0
        let leftColor = description.leftColor
        let leftWidth = description.leftWidth
        let right = position.x + size.x /// 2.0
        let rightWidth = description.rightWidth
        let rightColor = description.rightColor
        let top = position.y
        let topWidth = description.topWidth
        let topColor = description.topColor
        let bottom = position.y + size.y
        let bottomWidth = description.bottomWidth
        let bottomColor = description.bottomColor
        
        self.fillRectangle(position: .init(x: left, y: top), size: .init(x: leftWidth, y: size.y), color: leftColor)
        self.fillRectangle(position: .init(x: position.x, y: top), size: .init(x: size.x, y: topWidth), color: topColor)
        self.fillRectangle(position: .init(x: right, y: top), size: .init(x: rightWidth, y: size.y), color: rightColor)
        self.fillRectangle(position: .init(x: left, y: bottom), size: .init(x: size.x, y: bottomWidth), color: bottomColor)
    }
    
    func border() {
        guard let layout = self.layoutStack.last else { return }
        guard let size = layout.size else { return }
        self.border(position: layout.position, size: size, description: self.getRenderProperties().border)
    }
    
    func text(text: String) {
        guard let layout = self.layoutStack.last else { return }
        let textInstanceData = self.textInstanceData(text: text, position: layout.position, color: _currentProperties.foregroundColor, fontSize: 22.0)
        self._instanceData.append(textInstanceData)
    }
    
    func getSize(text: String) -> simd_float2 {
        self.textManager.getRenderInfo(text: text, fontName: "System", color: .zero, size: 22.0)?.rect.size.toSimd() ?? .zero
    }
}


class GuiUpdater : GuiViewBuilderBase, GuiMutater {
    func fillRectangle() {
        
    }
    
    func border(position: simd_float2, size: simd_float2, description: BorderProperty) {
        
    }
    
    func border() {
        
    }
    
    func text(text: String) {
        
    }
    
    func getSize(text: String) -> simd_float2 {
        return .zero
    }
    
    private let _numberOfInstances : Int
    private var _instanceBuffer : MTLBuffer
    private var _instancePointer : UnsafeMutablePointer<GuiInstanceData>
    private var _baseInstanceIndex : Int = 0
    
    init (worldProjection: float4x4, size: simd_float2, instanceBuffer: MTLBuffer, numberOfInstances: Int, textManager: TextManager) {
        _instanceBuffer = instanceBuffer
        _numberOfInstances = numberOfInstances
        _instancePointer = _instanceBuffer.contents().bindMemory(to: GuiInstanceData.self, capacity: _numberOfInstances)
        super.init(worldProjection: worldProjection, size: size, textManager: textManager)
    }
    
    func setBaseInstanceIndex(_ baseIndex: Int) {
        self._baseInstanceIndex = baseIndex
    }
    
    func fillRectangle(position: simd_float2, size: simd_float2, color: simd_float4) {
        let rectangleInstanceData = self.rectangleInstanceData(position: position, size: size, color: color)
        patchInstanceData(rectangleInstanceData)
    }
    
    private func patchInstanceData(_ instanceData: GuiInstanceData) {
        _instancePointer[self._baseInstanceIndex] = instanceData
        self._baseInstanceIndex += 1
    }
}

