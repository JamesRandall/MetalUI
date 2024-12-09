//
//  PaddingModifier.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Combine
import simd

/*@MainActor
struct PaddingDescription {
    var border: [Border]
    var width : Float
    
    public static let none = PaddingDescription(border: [.all], width: 0.0)
}*/


struct PaddingModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let paddingRef: ValueRef<InsetDescription>
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, padding: InsetDescription) {
        self.content = content
        self.paddingRef = ValueRef(padding)
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var padding : InsetDescription { paddingRef.value }
}


extension View {
    public func padding(_ border: [Border], width: Float) -> some View {
        PaddingModifier(content: AnyView(self), padding: InsetDescription(border: border, width: width))
    }
    
    public func padding(_ width: Float) -> some View {
        PaddingModifier(content: AnyView(self), padding: InsetDescription(border: [.all], width: width))
    }
}
