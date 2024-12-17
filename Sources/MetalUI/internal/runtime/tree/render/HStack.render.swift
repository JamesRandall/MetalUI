//
//  VStack.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

import simd

extension RenderTree {
    static func render(hstack: HStack, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        let spacerCount = hstack.children.count(where: { $0 is Spacer })
        let sizeTaken = hstack.children.reduce(Float(0.0), { x, child in
            if !(child is Spacer) {
                let size = getRequestedSize(child, builder: builder)
                return x + size.footprint.x + hstack.spacing
            }
            return x + hstack.spacing
        })
        let remainingWidth = requestedSize.contentZone.x - sizeTaken + hstack.spacing
        let spacerHeight = remainingWidth / Float(spacerCount)
        let _ = hstack.children.reduce(Float(0.0), { x,child in
            if child is Spacer {
                return x + hstack.spacing + spacerHeight
            } else {
                builder.pushPropagatingProperty(position: simd_float2(x, 0.0))
                let size = renderTree(child, builder: builder, maxWidth: requestedSize.contentZone.x - x, maxHeight: requestedSize.contentZone.y)
                builder.popPropagatingProperty()
                return x + size.footprint.x + hstack.spacing
            }
        })
    }
}

