//
//  PaddingModifier.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Combine
import simd


struct PressedModifier : HasStateTriggeredContent, RequiresRuntimeRef {
    internal let content : AnyView
    internal let pressed : [any View]
    internal var runtimeRef = RuntimeRef()
    
    init (content: AnyView, @ViewBuilder pressed: () -> [any View]) {
        self.content = content
        self.pressed = pressed()
    }
    
    var body : some View { return AnyView(self.content) }
}


extension HasStateTriggeredContent {
    public func pressed(@ViewBuilder content: @escaping () -> [any View]) -> some HasStateTriggeredContent {
        PressedModifier(content: AnyView(self), pressed: content)
    }
}
