//
//  MarginModifier.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import Combine
import simd

/*
@MainActor
struct MarginDescription {
    var border: [Border]
    var width : Float
    
    public static let none = MarginDescription(border: [.all], width: 0.0)
    
    public var totalHorizontalMarginWidth : Float { get {
        if border.contains(.all) {
            return width * 2.0
        }
        return (border.contains(.left) ? width : 0.0) + (border.contains(.right) ? width : 0.0)
    }}
    
    public var totalVerticalMarginHeight : Float { get {
        if border.contains(.all) {
            return width * 2.0
        }
        return (border.contains(.top) ? width : 0.0) + (border.contains(.bottom) ? width : 0.0)
    }}
    
    public var left : Float { get {
        border.contains(.all) || border.contains(.left) ? width : 0.0
    }}
    
    public var top : Float { get {
        border.contains(.all) || border.contains(.top) ? width : 0.0
    }}
}
 */

struct MarginModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let marginRef: ValueRef<InsetDescription>
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, margin: InsetDescription) {
        self.content = content
        self.marginRef = ValueRef(margin)
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var margin : InsetDescription { marginRef.value }
}


extension View {
    public func margin(_ border: [Border], width: Float) -> some View {
        MarginModifier(content: AnyView(self), margin: InsetDescription(border: border, width: width))
    }
    
    public func margin(_ width: Float) -> some View {
        MarginModifier(content: AnyView(self), margin: InsetDescription(border: [.all], width: width))
    }
}
