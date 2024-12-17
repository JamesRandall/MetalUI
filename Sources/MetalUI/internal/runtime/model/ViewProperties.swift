//
//  ViewProperties.swift
//  MetalUI
//
//  Created by James Randall on 09/12/2024.
//

import simd
import Foundation

struct OptionalSize {
    var width : Float?
    var height : Float?
    
    func toSimd() -> simd_float2? {
        if let width = width, let height = height {
            return simd_float2(width, height)
        }
        return nil
    }
}

@MainActor
internal struct ViewProperties {
    var horizontalSizeToChildren : Bool = false
    var verticalSizeToChildren : Bool = false
    var backgroundColor = simd_float4(0.0, 0.0, 0.0, 0.0)
    var foregroundColor = simd_float4(1.0, 1.0, 1.0, 1.0)
    var position : simd_float2?
    var positionTranslation : ((simd_float2) -> simd_float2) = { $0 }
    var size : OptionalSize = OptionalSize()
    var margin : Inset = .zero
    var padding : Inset = .zero
    var fontName : String = ".SFUI-Regular"
    var fontSize : Float = 18.0
    var border : BorderProperty?
    var visible : Bool = true
    var hover : HoverModifier?
    var pressed : PressedModifier?
    
    //init() { }
    
    public static func getDefault() -> ViewProperties {
        ViewProperties()
    }
        
    func withSizeToChildren(horizontal: Bool, vertical: Bool) -> ViewProperties {
        var copy = self
        copy.horizontalSizeToChildren = horizontal
        copy.verticalSizeToChildren = vertical
        return copy
    }
    
    func with(backgroundColor: simd_float4) -> ViewProperties {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }
    
    func with(foregroundColor: simd_float4) -> ViewProperties {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }
    
    func with(position: simd_float2?, translation: @escaping ((simd_float2) -> simd_float2)) -> ViewProperties {
        var copy = self
        copy.position = position
        copy.positionTranslation = translation
        return copy
    }
    
    func with(size: OptionalSize) -> ViewProperties {
        var copy = self
        copy.size = size
        return copy
    }
    
    func with(fontName: String) -> ViewProperties {
        var copy = self
        copy.fontName = fontName
        return copy
    }
    
    func with(fontSize: Float) -> ViewProperties {
        var copy = self
        copy.fontSize = fontSize
        return copy
    }
    
    func with(visibility: Bool) -> ViewProperties {
        var copy = self
        copy.visible = visibility
        return copy
    }
    
    func with(hover: HoverModifier) -> ViewProperties {
        var copy = self
        copy.hover = hover
        return copy
    }
    
    func with(pressed: PressedModifier) -> ViewProperties {
        var copy = self
        copy.pressed = pressed
        return copy
    }
    
    func mergeBorderWith(borderDescription: BorderDescription) -> ViewProperties {
        let c = borderDescription.color
        let w = borderDescription.width
        var borderProperty = self.border ?? BorderProperty.none
        
        borderDescription.border.forEach({ side in
            if side == .all {
                borderProperty = BorderProperty(topColor: c, topWidth: w, leftColor: c, leftWidth: w, rightColor: c, rightWidth: w, bottomColor: c, bottomWidth: w)
            }
            else {
                switch side {
                case .bottom:
                    borderProperty.bottomColor = c
                    borderProperty.bottomWidth = w
                case .top:
                    borderProperty.topColor = c
                    borderProperty.topWidth = w
                case .left:
                    borderProperty.leftColor = c
                    borderProperty.leftWidth = w
                case .right:
                    borderProperty.rightColor = c
                    borderProperty.rightWidth = w
                default: ()
                }
            }
        })
        
        var copy = self
        copy.border = borderProperty
        return copy
    }
    
    func mergeMarginWith(insetDescription: InsetDescription) -> ViewProperties {
        var copy = self
        copy.margin = copy.margin.mergeWith(insetDescription: insetDescription)
        return copy
    }
    
    func mergePaddingWith(insetDescription: InsetDescription) -> ViewProperties {
        var copy = self
        copy.padding = copy.padding.mergeWith(insetDescription: insetDescription)
        return copy
    }
    
    func resetForChild() -> ViewProperties {
        return ViewProperties.getDefault()
    }
}
