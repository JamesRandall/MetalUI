//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
private func renderViewProperties<V: View>(_ view: V, builder: GuiViewBuilder, properties: ViewProperties, maxWidth: Float, maxHeight: Float) -> SizeInformation {
    if let position = properties.position {
        builder.pushPropagatingProperty(position: position)
    }
    if properties.margin.left != 0 || properties.margin.top != 0 {
        builder.pushPropagatingProperty(position: simd_float2(properties.margin.left, properties.margin.top))
    }
    let requestedSize = getRequestedSize(view, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
    builder.fillRectangle(with: properties, size: requestedSize.content)
    
    return requestedSize
}

@MainActor
func renderTree<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) -> SizeInformation {
    if let anyView = view as? AnyView {
        return anyView.boxAction({ renderTree($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
    }
    
    let startingStackSize = builder.getPropagatingPropertiesStackSize()
    var properties = ViewProperties.getDefault()
    if let propertyView = view as? any HasViewProperties {
        properties = propertyView.properties
    }
    let requestedSize = renderViewProperties(view, builder: builder, properties: properties, maxWidth: maxWidth, maxHeight: maxHeight)
    
    
    if let panel = view as? Panel {
        builder.resetForChild()
        panel.children.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.content.x, maxHeight: requestedSize.content.y ) })
    }
    else if let vstack = view as? VStack {
        builder.resetForChild()
        let _ = vstack.children.reduce(Float(0.0), { y,child in
            builder.pushPropagatingProperty(position: simd_float2(0.0, y))
            let size = renderTree(child, builder: builder, maxWidth: requestedSize.content.x, maxHeight: requestedSize.content.y - y)
            return y + size.footprint.y
        })
    }
    else if let text = view as? Text {
        builder.text(text: text.content, properties: properties)
    }
    
    // overlay rendering
    builder.border(with: properties, size: requestedSize.content)
    
    while (builder.getPropagatingPropertiesStackSize() > startingStackSize) {
        builder.popPropagatingProperty()
    }
    return requestedSize
}
