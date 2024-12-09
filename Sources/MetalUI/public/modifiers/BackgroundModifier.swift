//
//  BackgroundView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import Combine
import simd


struct BackgroundModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let backgroundRef: ValueRef<simd_float4>
    private var binding: Published<simd_float4>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, color: simd_float4) {
        self.content = content
        self.backgroundRef = ValueRef(color)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<simd_float4>.Publisher) {
        self.content = content
        self.backgroundRef = ValueRef(.zero)
        self.binding = binding
        self.cancellable = binding.sink { [weak backgroundRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            backgroundRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        self.content
    }
    
    var background : simd_float4 { backgroundRef.value }
}

extension View {
    public func background(_ color: simd_float4) -> some View {
        BackgroundModifier(content: AnyView(self), color: color)
    }
}
