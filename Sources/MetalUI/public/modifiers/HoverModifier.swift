//
//  PaddingModifier.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Combine
import simd

struct HoverModifier : HasStateTriggeredContent, RequiresRuntimeRef {
    internal let content : AnyView
    internal let hover : any View
    internal var runtimeRef = RuntimeRef()
    
    init (content: AnyView, @ViewBuilder hover: () -> some View) {
        self.content = content
        self.hover = hover()
    }
    
    var body : some View { return AnyView(self.content) }
}

extension HasStateTriggeredContent {
    public func hover(@ViewBuilder content: @escaping () -> some View) -> some HasStateTriggeredContent {
        HoverModifier(content: AnyView(self), hover: content)
    }
}
