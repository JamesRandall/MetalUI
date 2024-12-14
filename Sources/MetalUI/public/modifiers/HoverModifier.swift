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


struct HoverModifier : View, RequiresRuntimeRef {
    internal let content : AnyView
    internal let hover : [any View]
    internal var runtimeRef = RuntimeRef()
    
    init (content: AnyView, @ViewBuilder hover: () -> [any View]) {
        self.content = content
        self.hover = hover()
    }
    
    var body : some View { return AnyView(self.content) }
}


extension HasStateTriggeredContent {
    public func hover(@ViewBuilder content: @escaping () -> [any View]) -> some View {
        HoverModifier(content: AnyView(self), hover: content)
    }
}
