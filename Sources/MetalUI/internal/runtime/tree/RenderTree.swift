//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd
import CoreGraphics

@MainActor
class RenderTree {
    static func renderView<V: View>(_ view: V, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        if let vstack = view as? VStack {
            RenderTree.render(vstack: vstack, requestedSize: requestedSize, properties: properties, builder: builder)
        }
        else if let hstack = view as? HStack {
            RenderTree.render(hstack: hstack, requestedSize: requestedSize, properties: properties, builder: builder)
        }
        else if let view = view as? InteractivityStateBasedView {
            RenderTree.render(interactivityStateBasedView: view, requestedSize: requestedSize, properties: properties, builder: builder)
        }
        // default layout for an item that has children
        else if let hasChildrenView = view as? HasChildren {
            RenderTree.render(hasChildren: hasChildrenView, requestedSize: requestedSize, properties: properties, builder: builder)
        }
        else if let text = view as? Text {
            RenderTree.render(text: text, requestedSize: requestedSize, properties: properties, builder: builder)
        }
        else if let image = view as? Image {
            RenderTree.render(image: image, requestedSize: requestedSize, properties: properties, builder: builder)
        }
    }
    
    static func renderTree<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) -> SizeInformation {
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
}

// TODO: Currently sizing occurs alongside rendering and so can involve multiple traverses down the same tree path
// to get the requested sizes. A preprocessing step may optimise this.

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
    let requestedSize = getFinalSize(view, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight)
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


