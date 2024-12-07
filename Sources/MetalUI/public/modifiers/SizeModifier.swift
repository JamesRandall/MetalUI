//
//  PositionedView.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Combine
import CoreGraphics
import simd

struct SizeModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let sizeRef: ValueRef<simd_float2>
    private var binding: Published<simd_float2>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, size: simd_float2) {
        self.content = content
        self.sizeRef = ValueRef(size)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<simd_float2>.Publisher) {
        self.content = content
        self.sizeRef = ValueRef(.zero)
        self.binding = binding
        self.cancellable = binding.sink { [weak sizeRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            sizeRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var size : simd_float2 { sizeRef.value }
}

public extension View {
    
    func size(_ size: CGSize) -> some View {
        SizeModifier(content: AnyView(self), size: simd_float2(Float(size.width), Float(size.height)))
    }
    
    func size(_ size: simd_float2) -> some View {
        SizeModifier(content: AnyView(self), size: size)
    }
    
    
    func size(_ binding:Published<simd_float2>.Publisher) -> some View {
        SizeModifier(content: AnyView(self), binding: binding)
    }
}
