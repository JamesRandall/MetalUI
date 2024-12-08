//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
func renderTree<V: View>(_ view: V, builder: GuiViewBuilder) {
    if let anyView = view as? AnyView {
        anyView.boxAction({ renderTree($0, builder: builder) })
        return
    }
    
    let startingRenderProperties = builder.getRenderProperties()
    let startingStackSize = builder.getLayoutStackSize()
    
    if let panel = view as? Panel {
        let requestedSize = getRequestedSize(view, builder: builder)
        builder.pushAutoSizeIfRequired(requestedSize: requestedSize)
        
        builder.fillRectangle()
        panel.children.forEach({ renderTree($0, builder: builder) })
    }
    else if let vstack = view as? VStack {
        let requestedSize = getRequestedSize(view, builder: builder)
        builder.pushAutoSizeIfRequired(requestedSize: requestedSize)
        
        builder.fillRectangle()
        let _ = vstack.children.reduce(Float(0.0), { y,child in
            let size = getRequestedSize(child, builder: builder)
            builder.pushLayout(position: simd_float2(0.0, y))
            renderTree(child, builder: builder)
            return y + size.y
        })
    }
    else if let text = view as? Text {
        builder.text(text: text.content)
    }
    else if let arvv = view as? AnyResolvedValueView {
        arvv.applyValue(with: builder)
        renderTree(arvv.content, builder: builder)
    }
    else if let av = view as? ActionView {
        av.applyValue(with: builder)
        renderTree(av.content, builder: builder)
    }
    
    // overlay rendering
    if !(view is AnyResolvedValueView || view is ActionView) {
        // if children have made modifications then we reset them here so we're looking at our render properties
        // before drawing the overlay
        builder.setRenderProperties(startingRenderProperties)
        builder.border()
    }
    
    while (builder.getLayoutStackSize() > startingStackSize) {
        builder.popLayout()
    }
    
}
