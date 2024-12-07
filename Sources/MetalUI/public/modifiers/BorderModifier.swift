//
//  AnchorModifier.swift
//  starship-tactics
//
//  Created by James Randall on 07/12/2024.
//

import Combine
import simd

let defaultBorderWidth : Float = 2.0

public enum Border {
    case left
    case top
    case right
    case bottom
    case all
}

@MainActor
struct BorderDescription {
    var border: [Border]
    var color : simd_float4
    var width : Float
    
    public static let none = BorderDescription(border: [.all], color:.zero, width: 0.0)
}

struct BorderModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let borderRef: ValueRef<BorderDescription>
    private var colorBinding : Published<simd_float4>.Publisher?
    private var widthBinding : Published<Float>.Publisher?
    private var colorCancellable: AnyCancellable?
    private var widthCancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, border: BorderDescription) {
        self.content = content
        self.borderRef = ValueRef(border)
        self.colorBinding = nil
        self.colorCancellable = nil
        self.widthBinding = nil
        self.widthCancellable = nil
    }
    
    init (content: AnyView, colorBinding: Published<simd_float4>.Publisher?, widthBinding: Published<Float>.Publisher?) {
        self.content = content
        self.borderRef = ValueRef(BorderDescription.none)
        self.colorBinding = colorBinding
        self.colorCancellable = colorBinding?.sink { [weak borderRef, weak runtimeRef] newValue in
            borderRef?.value.color = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
        self.widthBinding = widthBinding
        self.widthCancellable = widthBinding?.sink { [weak borderRef, weak runtimeRef] newValue in
            borderRef?.value.width = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var border : BorderDescription { borderRef.value }
}


private class ConstantBorderProvider {
    @Published var color: simd_float4 = simd_float4(0.0, 0.0, 0.0, 0.0) // Red color
    @Published var width: Float = defaultBorderWidth                                // Width

    var colorPublisher: Published<simd_float4>.Publisher {
        $color
    }

    var widthPublisher: Published<Float>.Publisher {
        $width
    }
}

// Instantiate the provider
@MainActor
private let constantBorderProvider = ConstantBorderProvider()

extension View {
    public func borderColors(border: [Border], color: Published<simd_float4>.Publisher?) -> some View {
        BorderModifier(content: AnyView(self), colorBinding: color, widthBinding: constantBorderProvider.widthPublisher)
    }
    
    public func borderColors(border: Border, color: Published<simd_float4>.Publisher?) -> some View {
        borderColors(border: [border], color: color)
    }
    
    public func borderColors(border: [Border], color: Published<simd_float4>.Publisher?, width: Published<Float>.Publisher?) -> some View {
        BorderModifier(content: AnyView(self), colorBinding: color, widthBinding: width)
    }
    
    public func borderColors(border: Border, color: Published<simd_float4>.Publisher?, width: Published<Float>.Publisher?) -> some View {
        borderColors(border: [border], color: color, width: width)
    }
    
    public func borderColors(border: [Border], color: simd_float4) -> some View {
        BorderModifier(content: AnyView(self), border: BorderDescription(border: border, color: color, width: defaultBorderWidth))
    }
    
    public func borderColors(border: [Border], color: simd_float4, width: Float) -> some View {
        BorderModifier(content: AnyView(self), border: BorderDescription(border: border, color: color, width: width))
    }
}
