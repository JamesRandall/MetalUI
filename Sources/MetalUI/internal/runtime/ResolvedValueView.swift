//
//  ResolvedExplicitLayoutView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

// with the Swift type system just easier to keep this limited case like this
enum LayoutType {
    case none, position, size
}

@MainActor
protocol AnyResolvedValueView {
    func applyValue(with: GuiViewBuilder)
    
    var content : AnyView { get }
    
    var layoutType : LayoutType { get }
}

struct ResolvedValueView<TValue> : View, AnyResolvedValueView, RequiresRuntimeRef {
    var runtimeRef = RuntimeRef()
    var value : TValue
    let content : AnyView
    var apply : (TValue, GuiViewBuilder) -> ()
    var layoutType : LayoutType
    
    init (content: AnyView, value: TValue, apply: @escaping (TValue, GuiViewBuilder) -> (), layoutType: LayoutType = .none) {
        self.content = content
        self.value = value
        self.apply = apply
        self.layoutType = layoutType
    }
    
    var body : some View {
        content
    }
    
    internal func applyValue(with: GuiViewBuilder) {
        apply(value, with)
    }
}
