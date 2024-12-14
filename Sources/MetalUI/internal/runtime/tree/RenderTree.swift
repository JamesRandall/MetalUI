//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
private func renderViewProperties<V: View>(_ view: V, builder: GuiViewBuilder, properties: ViewProperties, maxWidth: Float, maxHeight: Float) -> SizeInformation {
    if !properties.visible {
        builder.pushPropagatingProperty(visibility: false)
    }
    if let position = properties.position {
        let translation = properties.positionTranslation
        builder.pushPropagatingProperty(position: translation(position))
    }
    if properties.margin.left != 0 || properties.margin.top != 0 {
        builder.pushPropagatingProperty(position: simd_float2(properties.margin.left, properties.margin.top))
    }
    let requestedSize = getRequestedSize(view, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
    builder.fillRectangle(with: properties, size: requestedSize.paddingZone)
    
    if properties.padding.left != 0 || properties.padding.top != 0 {
        builder.pushPropagatingProperty(position: simd_float2(properties.padding.left, properties.padding.top))
    }
    
    return requestedSize
}

@MainActor
private func renderOverlay(requestedSize: SizeInformation, builder: GuiViewBuilder, properties: ViewProperties) {
    // we could lean on the renderViewProperties above and just pop the padding position but that feels frail
    // and more resilient to set up the position stack again.
    if let position = properties.position {
        let translation = properties.positionTranslation
        builder.pushPropagatingProperty(position: translation(position))
    }
    builder.pushPropagatingProperty(position: simd_float2(properties.margin.left, properties.margin.top))
    builder.border(with: properties, size: requestedSize.paddingZone)
    builder.popPropagatingProperty()
    if let _ = properties.position {
        builder.popPropagatingProperty()
    }
}

@MainActor func renderView<V: View>(_ view: V, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
    if let vstack = view as? VStack {
        builder.resetForChild()
        let _ = vstack.children.reduce(Float(0.0), { y,child in
            builder.pushPropagatingProperty(position: simd_float2(0.0, y))
            let size = renderTree(child, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y - y)
            builder.popPropagatingProperty()
            return y + size.footprint.y
        })
    }
    // default layout for an item that has children
    else if let hasChildrenView = view as? HasChildren {
        builder.resetForChild()
        hasChildrenView.children.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
    }
    else if let text = view as? Text {
        builder.text(text: text.content, properties: properties)
    }
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
    renderView(view, requestedSize: requestedSize, properties: properties, builder: builder)
    
    while (builder.getPropagatingPropertiesStackSize() > startingStackSize) {
        builder.popPropagatingProperty()
    }
    
    renderOverlay(requestedSize: requestedSize, builder: builder, properties: properties)
    
    return requestedSize
}
