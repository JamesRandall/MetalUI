//
//  ResolvedExplicitLayoutView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

@MainActor
protocol AnyResolvedValueView {
    func applyValue(with: GuiViewBuilder)
    
    var content : AnyView { get }
}

struct ResolvedValueView<TValue> : View, AnyResolvedValueView, RequiresRuntimeRef {
    var runtimeRef = RuntimeRef()
    var value : TValue
    let content : AnyView
    var apply : (TValue, GuiViewBuilder) -> ()
    
    init (content: AnyView, value: TValue, apply: @escaping (TValue, GuiViewBuilder) -> ()) {
        self.content = content
        self.value = value
        self.apply = apply
    }
    
    var body : some View {
        content
    }
    
    internal func applyValue(with: GuiViewBuilder) {
        apply(value, with)
    }
}
