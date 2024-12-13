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
    var autoSizeMode: AutoSizeMode
    var visible: Bool
    
    func with(position: simd_float2) -> PropagatingRenderProperties {
        var copy = self
        copy.position = position
        return copy
    }
    
    func with(autoSizeMode: AutoSizeMode) -> PropagatingRenderProperties {
        var copy = self
        copy.autoSizeMode = autoSizeMode
        return copy
    }
    
    func with(visibility: Bool) -> PropagatingRenderProperties {
        var copy = self
        copy.visible = visibility
        return copy
    }
    
    static let zero = PropagatingRenderProperties(position: .zero, autoSizeMode: .toParent, visible: true)
}
