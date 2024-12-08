//
//  BackgroundView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import Combine
import simd


struct ForegroundColorModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let colorRef: ValueRef<simd_float4>
    private var binding: Published<simd_float4>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, color: simd_float4) {
        self.content = content
        self.colorRef = ValueRef(color)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<simd_float4>.Publisher) {
        self.content = content
        self.colorRef = ValueRef(.zero)
        self.binding = binding
        self.cancellable = binding.sink { [weak colorRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            colorRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var foreground : simd_float4 { colorRef.value }
}

extension View {
    public func foregroundColor(_ color: simd_float4) -> some View {
        BackgroundModifier(content: AnyView(self), color: color)
    }
}
