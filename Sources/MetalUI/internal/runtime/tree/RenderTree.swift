//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
private func renderViewProperties<V: View>(_ view: V, builder: GuiViewBuilder, properties: ViewProperties, maxWidth: Float, maxHeight: Float) -> simd_float2 {
    if let position = properties.position {
        builder.pushPropagatingProperty(position: position)
    }
    if properties.margin.left != 0 || properties.margin.top != 0 {
        builder.pushPropagatingProperty(position: simd_float2(properties.margin.left, properties.margin.top))
    }
    if let fontName = properties.fontName {
        builder.pushPropagatingProperty(fontName: fontName)
    }
    if let fontSize = properties.fontSize {
        builder.pushPropagatingProperty(fontSize: fontSize)
    }
    let requestedSize = getRequestedSize(view, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
    builder.fillRectangle(with: properties, size: requestedSize)
    
    return requestedSize
}

@MainActor
func renderTree<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) {
    if let anyView = view as? AnyView {
        anyView.boxAction({ renderTree($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
        return
    }
    
    let startingStackSize = builder.getPropagatingPropertiesStackSize()
    var properties = ViewProperties.getDefault()
    if let propertyView = view as? any HasViewProperties {
        properties = propertyView.properties
    }
    let requestedSize = renderViewProperties(view, builder: builder, properties: properties, maxWidth: maxWidth, maxHeight: maxHeight)
    
    
    if let panel = view as? Panel {
        builder.resetForChild()
        panel.children.forEach({ renderTree($0, builder: builder, maxWidth: requestedSize.x, maxHeight: requestedSize.y ) })
    }
    else if let vstack = view as? VStack {
        let _ = vstack.children.reduce(Float(0.0), { y,child in
            let size = getRequestedSize(child, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
            builder.pushPropagatingProperty(position: simd_float2(0.0, y))
            renderTree(child, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
            return y + size.y
        })
    }
    else if let text = view as? Text {
        builder.text(text: text.content, properties: properties)
    }
    else if let arvv = view as? AnyResolvedValueView {
        arvv.applyValue(with: builder)
        renderTree(arvv.content, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight )
    }
    else if let av = view as? ActionView {
        av.applyValue(with: builder)
        renderTree(av.content, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight )
    }
    
    // overlay rendering
    if !(view is AnyResolvedValueView || view is ActionView) {
        // if children have made modifications then we reset them here so we're looking at our render properties
        // before drawing the overlay
        builder.border(with: properties, size: requestedSize)
    }
    
    while (builder.getPropagatingPropertiesStackSize() > startingStackSize) {
        builder.popPropagatingProperty()
    }
    
}
