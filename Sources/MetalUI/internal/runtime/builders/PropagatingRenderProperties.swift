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
    
    static let zero = PropagatingRenderProperties(position: .zero, size: nil, parentSize: .zero, autoSizeMode: .toParent)
}
