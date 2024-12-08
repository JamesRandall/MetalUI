//
//  GuiMetalBuilder.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Metal
import simd

protocol GameObject {
    var position: simd_float3 { get }
}

protocol GameObjectLocator {
    func getGameObject(id:UUID) -> GameObject?
}

@MainActor
protocol GuiMutater {
    func getLayout() -> RenderLayout
    func getLayoutStackSize() -> Int
    func pushLayout(position:simd_float2)
    func pushLayout(size:simd_float2)
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
}

protocol GuiViewBuilder : GuiMutater {
    
}

struct RenderLayout {
    var position: simd_float2
    var size: simd_float2
    
    static let zero = RenderLayout(position: .zero, size: .zero)
}

struct BorderProperty {
    var topColor: simd_float4
    var topWidth: Float
    var leftColor: simd_float4
    var leftWidth: Float
    var rightColor: simd_float4
    var rightWidth: Float
    var bottomColor: simd_float4
    var bottomWidth: Float
    
    // we default to it being transparent but always draw it - this means we don't have to mess around with the instance data on a bordered
    // element
    static let none = BorderProperty(topColor: .zero, topWidth: 1.0, leftColor: .zero, leftWidth: 1.0, rightColor: .zero, rightWidth: 1.0, bottomColor: .zero, bottomWidth: 1.0)
}

struct RenderProperties {
    var backgroundColor : simd_float4
    var foregroundColor : simd_float4
    var border: BorderProperty
    
    static let zero = RenderProperties(backgroundColor: .zero, foregroundColor: .one, border: .none)
}

internal class GuiViewBuilderBase {
    let worldProjection : float4x4
    var layoutStack: [RenderLayout]
    var _currentProperties : RenderProperties
    let boundsSize : simd_float2
    let textManager : TextManager
    
    init (worldProjection: float4x4, size: simd_float2, textManager: TextManager) {
        self.worldProjection = worldProjection
        layoutStack = [RenderLayout(position: .zero, size: size)]
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
    
    func pushLayout(position:simd_float2) {
        let tipLayout = getLayout()
        let newLayout = RenderLayout(position: tipLayout.position + position, size: tipLayout.size)
        layoutStack.append(newLayout)
    }
    
    func pushLayout(size:simd_float2) {
        let tipLayout = getLayout()
        let newLayout = RenderLayout(position: tipLayout.position, size: size)
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
        layoutStack.append(RenderLayout(position: tipLayout.position, size: .zero))
        _currentProperties = .zero
    }
    
    func popLayout() {
        layoutStack.removeLast()
    }
}

internal class GuiViewBuilderImpl : GuiViewBuilderBase, GuiViewBuilder {
    private var _instanceData : [GuiInstanceData] = []
    
    var instanceData: [GuiInstanceData] { _instanceData }
    
    func fillRectangle(position: simd_float2, size: simd_float2, color: simd_float4) {
        let rectangleInstanceData = self.rectangleInstanceData(position: position, size: size, color: color)
        self._instanceData.append(rectangleInstanceData)
    }
    
    func fillRectangle() {
        guard let layout = self.layoutStack.last else { return }
        self.fillRectangle(position: layout.position, size: layout.size, color: self.getRenderProperties().backgroundColor)
    }
    
    func border(position: simd_float2, size: simd_float2, description: BorderProperty) {
        if description.leftColor.z == 0.0 { return }
        
        let left = position.x// - size.x / 2.0
        let leftColor = description.leftColor
        let leftWidth = description.leftWidth
        let right = position.x + size.x /// 2.0
        let rightWidth = description.rightWidth
        let rightColor = description.rightColor
        let top = position.y + size.y /// 2.0
        let topWidth = description.topWidth
        let topColor = description.topColor
        let bottom = position.y //- size.y// / 2.0
        let bottomWidth = description.bottomWidth
        let bottomColor = description.bottomColor
        
        self.fillRectangle(position: .init(x: left, y: bottom), size: .init(x: leftWidth, y: size.y), color: leftColor)
        self.fillRectangle(position: .init(x: position.x, y: top), size: .init(x: size.x, y: topWidth), color: topColor)
        self.fillRectangle(position: .init(x: right, y: bottom), size: .init(x: rightWidth, y: size.y), color: rightColor)
        self.fillRectangle(position: .init(x: left, y: bottom), size: .init(x: size.x, y: bottomWidth), color: bottomColor)
    }
    
    func border() {
        guard let layout = self.layoutStack.last else { return }
        self.border(position: layout.position, size: layout.size, description: self.getRenderProperties().border)
    }
    
    func text(text: String) {
        guard let layout = self.layoutStack.last else { return }
        let textInstanceData = self.textInstanceData(text: text, position: layout.position, color: _currentProperties.foregroundColor, fontSize: 22.0)
        self._instanceData.append(textInstanceData)
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

