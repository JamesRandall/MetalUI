//
//  ViewProperties.swift
//  MetalUI
//
//  Created by James Randall on 09/12/2024.
//

import simd

@MainActor
internal struct ViewProperties {
    var sizeToChildren : Bool = false
    var backgroundColor : simd_float4?
    var foregroundColor : simd_float4?
    var position : simd_float2?
    var size : simd_float2?
    var margin : Inset = .zero
    var padding : Inset = .zero
    var fontName : String?
    var fontSize : Float?
    var border : BorderProperty?
    
    //init() { }
    
    public static func getDefault() -> ViewProperties {
        ViewProperties()
    }
    
    func with(sizeToChildren: Bool) -> ViewProperties {
        var copy = self
        copy.sizeToChildren = sizeToChildren
        return copy
    }
    
    func with(backgroundColor: simd_float4?) -> ViewProperties {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }
    
    func with(foregroundColor: simd_float4?) -> ViewProperties {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }
    
    func with(position: simd_float2?) -> ViewProperties {
        var copy = self
        copy.position = position
        return copy
    }
    
    func with(size: simd_float2?) -> ViewProperties {
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
