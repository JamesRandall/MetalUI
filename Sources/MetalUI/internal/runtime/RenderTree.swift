//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

extension [simd_float2] {
    func maxSize() -> simd_float2 {
        self.reduce(simd_float2.zero, { m,sz in simd_float2(Swift.max(m.x,sz.x), Swift.max(m.y,sz.y)) })
    }
}

@MainActor
func getRequestedSize<V: View>(_ view: V, builder: GuiViewBuilder) -> simd_float2 {
    if let anyView = view as? AnyView {
        return anyView.boxAction<simd_float2>({ getRequestedSize($0, builder: builder) })
    }
    else if let text = view as? Text {
        return builder.getSize(text: text.content)
    }
    else if let vs = view as? VStack {
        let sz = vs.children.reduce(simd_float2(0.0,0.0), { size,child in
            let childSize = getRequestedSize(child, builder: builder)
            return simd_float2(max(size.x, childSize.x), size.y + childSize.y)
        })
    }
    else if let arvv = view as? AnyResolvedValueView {
        //arvv.applyValue(with: builder)
        if arvv.layoutType == .size {
            if let sizeView = arvv as? ResolvedValueView<simd_float2> {
                return sizeView.value
            }
            else {
                fatalError("This should not be possible")
            }
        }
        return getRequestedSize(arvv.content, builder: builder)
    }
    else if let av = view as? ActionView {
        return getRequestedSize(av.content, builder: builder)
    }
    else if let hc = view as? HasChildren {
        // catch all for views that have children but don't size specifically themselves, any views with children that do
        // resize themselves should come before that
        return hc.children
            .map({ getRequestedSize($0, builder: builder) })
            .maxSize()
    }
    // failing all else we return the current size on the stack
    return builder.getLayout().size
}

@MainActor
func renderTree<V: View>(_ view: V, builder: GuiViewBuilder) {
    if let anyView = view as? AnyView {
        anyView.boxAction({ renderTree($0, builder: builder) })
        return
    }
    
    let startingRenderProperties = builder.getRenderProperties()
    let startingStackSize = builder.getLayoutStackSize()
    if let panel = view as? Panel {
        builder.fillRectangle()
        panel.children.forEach({ renderTree($0, builder: builder) })
    }
    else if let vstack = view as? VStack {
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
