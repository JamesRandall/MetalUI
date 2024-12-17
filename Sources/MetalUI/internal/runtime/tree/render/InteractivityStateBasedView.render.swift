//
//  InteractivityStateBasedView.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

import simd
import CoreGraphics

extension RenderTree {
    static func render(interactivityStateBasedView view: InteractivityStateBasedView, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        // we render all states but mark the none-active states as hidden
        // this allows us to keep a constant instance buffer size
        builder.resetForChild()
        builder.registerInteractiveZone(
            viewId: view.stateTrackingId,
            zone: CGRect(
                origin: builder.getPropagatingProperties().position.toCGPoint(),
                size: requestedSize.contentZone.toCGSize()
            )
        )
        
        let state = builder.getStateFor(view: view)
        //print("rendering \(hasChildrenView.stateTrackingId) with state \(state)")
        if state != .normal { builder.pushPropagatingProperty(visibility: false) }
        view.children.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .normal { builder.popPropagatingProperty() }
        
        if state != .hover { builder.pushPropagatingProperty(visibility: false) }
        view.hoverChildren.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .hover { builder.popPropagatingProperty() }
        
        if state != .pressed { builder.pushPropagatingProperty(visibility: false) }
        view.pressedChildren.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
        if state != .pressed { builder.popPropagatingProperty() }
    }
}
