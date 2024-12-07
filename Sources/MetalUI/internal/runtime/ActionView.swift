//
//  ActionView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//


struct ActionView : View, RequiresRuntimeRef {
    var runtimeRef = RuntimeRef()
    let content : AnyView
    var apply : (GuiViewBuilder) -> ()
    
    init (content: AnyView, apply: @escaping (GuiViewBuilder) -> ()) {
        self.content = content
        self.apply = apply
    }
    
    var body : some View {
        content
    }
    
    func applyValue(with: GuiViewBuilder) {
        apply(with)
    }
}
