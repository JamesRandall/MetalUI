//
//  VStack.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

import simd

extension RenderTree {
    static func render(vstack: VStack, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
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
}

