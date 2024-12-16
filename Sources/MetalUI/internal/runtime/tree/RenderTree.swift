//
//  RenderTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd
import CoreGraphics

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

@MainActor func renderView<V: View>(_ view: V, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
    if let vstack = view as? VStack {
        builder.resetForChild()
        let spacerCount = vstack.children.count(where: { $0 is Spacer })
        let sizeTaken = vstack.children.reduce(Float(0.0), { y, child in
            if !(child is Spacer) {
                let size = getRequestedSize(child, builder: builder)
                return y + size.footprint.y + vstack.spacing
            }
            return y + vstack.spacing
        })
        let remainingHeight = requestedSize.contentZone.y - sizeTaken + vstack.spacing
        let spacerHeight = remainingHeight / Float(spacerCount)
        let _ = vstack.children.reduce(Float(0.0), { y,child in
            if child is Spacer {
                return y + vstack.spacing + spacerHeight
            } else {
                builder.pushPropagatingProperty(position: simd_float2(0.0, y))
                let size = renderTree(child, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y - y)
                builder.popPropagatingProperty()
                return y + size.footprint.y + vstack.spacing
            }
        })
    }
    else if let hasChildrenView = view as? HasStateTriggeredChildren {
        // we render all states but mark the none-active states as hidden
        // this allows us to keep a constant instance buffer size
        builder.resetForChild()
        builder.registerInteractiveZone(
            viewId: hasChildrenView.stateTrackingId,
            zone: CGRect(
                origin: builder.getPropagatingProperties().position.toCGPoint(),
                size: requestedSize.contentZone.toCGSize()
            )
        )
        
        let state = builder.getStateFor(view: hasChildrenView)
        //print("rendering \(hasChildrenView.stateTrackingId) with state \(state)")
        if state != .normal { builder.pushPropagatingProperty(visibility: false) }
        hasChildrenView.children.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .normal { builder.popPropagatingProperty() }
        
        if state != .hover { builder.pushPropagatingProperty(visibility: false) }
        hasChildrenView.hoverChildren.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .hover { builder.popPropagatingProperty() }
        
        if state != .pressed { builder.pushPropagatingProperty(visibility: false) }
        hasChildrenView.pressedChildren.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .pressed { builder.popPropagatingProperty() }
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
