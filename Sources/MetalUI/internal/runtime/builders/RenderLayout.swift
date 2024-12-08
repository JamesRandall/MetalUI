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

struct RenderLayout {
    var position: simd_float2
    var size: simd_float2?
    var parentSize: simd_float2
    var autoSizeMode: AutoSizeMode
    
    func withPosition(position: simd_float2) -> RenderLayout {
        var copy = self
        copy.position = position
        return copy
    }
    
    func withSize(size: simd_float2) -> RenderLayout {
        var copy = self
        copy.size = size
        return copy
    }
    
    func withParentSize(parentSize: simd_float2) -> RenderLayout {
        var copy = self
        copy.parentSize = parentSize
        return copy
    }
    
    func withAutoSizeMode(autoSizeMode: AutoSizeMode) -> RenderLayout {
        var copy = self
        copy.autoSizeMode = autoSizeMode
        return copy
    }
    
    static let zero = RenderLayout(position: .zero, size: nil, parentSize: .zero, autoSizeMode: .toParent)
}
