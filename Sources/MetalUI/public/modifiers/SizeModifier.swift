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
    private let sizeRef: ValueRef<OptionalSize>
    private var binding: Published<simd_float2>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, size: OptionalSize) {
        self.content = content
        self.sizeRef = ValueRef(size)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<simd_float2>.Publisher) {
        self.content = content
        self.sizeRef = ValueRef(OptionalSize())
        self.binding = binding
        self.cancellable = binding.sink { [weak sizeRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            sizeRef?.value = OptionalSize(width: newValue.x, height: newValue.y)
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var size : OptionalSize { sizeRef.value }
}

public extension View {
    
    func size(_ size: CGSize) -> some View {
        SizeModifier(content: AnyView(self), size: OptionalSize(width: Float(size.width), height: Float(size.height)))
    }
    
    func size(width: Float? = nil, height: Float? = nil) -> some View {
        SizeModifier(content: AnyView(self), size: OptionalSize(width: width, height: height))
    }
    
    func size(width: Double? = nil, height: Double? = nil) -> some View {
        SizeModifier(
            content: AnyView(self),
            size: OptionalSize(
                width: width != nil ? Float(width!) : nil,
                height: height != nil ? Float(height!) : nil
            )
        )
    }
    
    func size(_ size: simd_float2) -> some View {
        SizeModifier(content: AnyView(self), size: OptionalSize(width: size.x, height: size.y))
    }
    
    func size(_ binding:Published<simd_float2>.Publisher) -> some View {
        SizeModifier(content: AnyView(self), binding: binding)
    }
}
