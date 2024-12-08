//
//  PositionedView.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Combine
import CoreGraphics
import simd

struct PositionModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let positionRef: ValueRef<simd_float2>
    private var subscriptionManager: SubscriptionManager<simd_float2>?
    var runtimeRef = RuntimeRef()
    var translation: ((simd_float2) -> simd_float2) = { $0 }
    
    init (content: AnyView, position: simd_float2) {
        self.content = content
        self.positionRef = ValueRef(position)
    }
    
    init (content: AnyView, binding: Published<simd_float2>.Publisher, translation:((simd_float2) -> simd_float2)? = nil) {
        self.content = content
        self.positionRef = ValueRef(.zero)
        self.subscriptionManager = SubscriptionManager(
            binding: binding,
            positionRef: positionRef,
            runtimeRef: runtimeRef
        )
        self.translation = translation ?? { $0 }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var position : simd_float2 { positionRef.value }
}

extension View {
    public func position(_ position: CGPoint) -> some View {
        PositionModifier(content: AnyView(self), position: simd_float2(Float(position.x), Float(position.y)))
    }
    
    public func position(_ x: Float, _ y: Float) -> some View {
        PositionModifier(content: AnyView(self), position: simd_float2(x, y))
    }
    
    public func position(_ position: simd_float2) -> some View {
        PositionModifier(content: AnyView(self), position: position)
    }
    
    public func position(_ binding:Published<simd_float2>.Publisher, translation:((simd_float2) -> simd_float2)? = nil) -> some View {
        PositionModifier(content: AnyView(self), binding: binding, translation:translation)
    }
}
