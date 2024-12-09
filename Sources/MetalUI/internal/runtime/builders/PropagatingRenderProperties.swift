//
//  RenderLayout.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd

enum AutoSizeMode {
    case toChildren, toParent
}

struct PropagatingRenderProperties {
    var position: simd_float2
    var size: simd_float2?
    var parentSize: simd_float2
    var autoSizeMode: AutoSizeMode
    var fontName: String
    var fontSize: Float
    
    func with(position: simd_float2) -> PropagatingRenderProperties {
        var copy = self
        copy.position = position
        return copy
    }
    
    func with(size: simd_float2) -> PropagatingRenderProperties {
        var copy = self
        copy.size = size
        return copy
    }
    
    func with(parentSize: simd_float2) -> PropagatingRenderProperties {
        var copy = self
        copy.parentSize = parentSize
        return copy
    }
    
    func with(autoSizeMode: AutoSizeMode) -> PropagatingRenderProperties {
        var copy = self
        copy.autoSizeMode = autoSizeMode
        return copy
    }
    
    func with(fontName: String) -> PropagatingRenderProperties {
        var copy = self
        copy.fontName = fontName
        return copy
    }
    
    func with(fontSize: Float) -> PropagatingRenderProperties {
        var copy = self
        copy.fontSize = fontSize
        return copy
    }
    
    static let zero = PropagatingRenderProperties(position: .zero, size: nil, parentSize: .zero, autoSizeMode: .toParent, fontName: ".SFUI-Regular", fontSize: 18.0)
}
