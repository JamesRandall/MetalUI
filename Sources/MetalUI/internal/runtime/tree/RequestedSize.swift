//
//  RequestedSize.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd

extension [SizeInformation] {
    func maxSize() -> SizeInformation {
        let size = self.reduce(simd_float2.zero, { m,sz in simd_float2(Swift.max(m.x,sz.footprint.x), Swift.max(m.y,sz.footprint.y)) })
        return SizeInformation(footprint: size, paddingZone: size, contentZone: size)
    }
}

private func constrain(_ size:simd_float2, maxWidth: Float, maxHeight: Float) -> simd_float2 {
    simd_float2(min(size.x, maxWidth), min(size.y, maxHeight))
}

struct SizeInformation {
    var footprint: simd_float2
    var paddingZone: simd_float2
    var contentZone: simd_float2
    
    static let zero = SizeInformation(footprint: .zero, paddingZone: .zero, contentZone: .zero)
}

func applySizeToChildren(viewProperties: ViewProperties, parentSize: SizeInformation, childSize: SizeInformation) -> SizeInformation {
    return SizeInformation(
        footprint: simd_float2(
            viewProperties.horizontalSizeToChildren ? childSize.footprint.x : parentSize.footprint.x,
            viewProperties.verticalSizeToChildren ? childSize.footprint.y : parentSize.footprint.y),
        paddingZone: simd_float2(
            viewProperties.horizontalSizeToChildren ? childSize.paddingZone.x : parentSize.paddingZone.x,
            viewProperties.verticalSizeToChildren ? childSize.paddingZone.y : parentSize.paddingZone.y),
        contentZone: simd_float2(
            viewProperties.horizontalSizeToChildren ? childSize.contentZone.x : parentSize.contentZone.x,
            viewProperties.verticalSizeToChildren ? childSize.contentZone.y : parentSize.contentZone.y)
    )
}

// TODO: There is a lot of scope for optimisation in this

@MainActor
func getFinalSize<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) -> SizeInformation {
    if let anyView = view as? AnyView {
        return anyView.boxAction<simd_float2>({ getFinalSize($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
    }
    
    var properties = ViewProperties.getDefault()
    if let sizeConstraintView = view as? any HasViewProperties {
        properties = sizeConstraintView.properties
    }
    
    if properties.visible == false || view is Spacer {
        return .zero
    }
    
    let margin = simd_float2(properties.margin.horizontal, properties.margin.vertical)
    let padding = simd_float2(properties.padding.horizontal, properties.padding.vertical)
    
    if let absoluteSize = properties.size.toSimd() {
        return SizeInformation(
            footprint: absoluteSize + margin,
            paddingZone : absoluteSize - margin,
            contentZone: absoluteSize - margin - padding
        )
    }
    
    let maxWidth = maxWidth - properties.margin.horizontal
    let maxHeight = maxHeight - properties.margin.vertical
    
    // we can size to parent immediately if their is no size to children in place
    if !properties.horizontalSizeToChildren && !properties.verticalSizeToChildren {
        return SizeInformation(
            footprint: simd_float2(maxWidth, maxHeight),
            paddingZone: simd_float2(maxWidth, maxHeight) - margin,
            contentZone: simd_float2(maxWidth, maxHeight) - margin - padding
        )
    }
    let parentSize = SizeInformation(
        footprint: simd_float2(maxWidth, maxHeight),
        paddingZone: simd_float2(maxWidth, maxHeight) - margin,
        contentZone: simd_float2(maxWidth, maxHeight) - margin - padding
    )
    
    let requestedSize = getRequestedSize(view, builder: builder)
    let appliedSize = applySizeToChildren(viewProperties: properties, parentSize: parentSize, childSize: requestedSize)
    return appliedSize
}

@MainActor
func getRequestedSize<V: View>(_ view: V, builder: GuiViewBuilder) -> SizeInformation {
    if let anyView = view as? AnyView {
        return anyView.boxAction<simd_float2>({ getRequestedSize($0, builder: builder ) })
    }
    
    var properties = ViewProperties.getDefault()
    if let sizeConstraintView = view as? any HasViewProperties {
        properties = sizeConstraintView.properties
    }
    
    if properties.visible == false {
        return .zero
    }
    
    let margin = simd_float2(properties.margin.horizontal, properties.margin.vertical)
    let padding = simd_float2(properties.padding.horizontal, properties.padding.vertical)
    if let absoluteSize = properties.size.toSimd() {
        return SizeInformation(
            footprint: absoluteSize + margin,
            paddingZone : absoluteSize - margin,
            contentZone: absoluteSize
        )
    }
    
    if let text = view as? Text {
        let textSize = builder.getSize(text: text.content, properties: properties)
        let sizeInformation = SizeInformation(
            footprint: textSize + margin + padding,
            paddingZone: textSize + padding,
            contentZone: textSize
        )
        return sizeInformation
    }
    else if let vs = view as? VStack {
        let content = vs.children.reduce(simd_float2(0.0,0.0), { sz,child in
            let childSize = getRequestedSize(child, builder: builder)
            return simd_float2(max(childSize.footprint.x, sz.x), sz.y + childSize.footprint.y + vs.spacing)
        }) - simd_float2(0.0, vs.spacing)
        
        let vstackSize = SizeInformation(
            footprint: content + margin + padding,
            paddingZone: content + padding,
            contentZone: content
        )
        return vstackSize
    }
    else if let hc = view as? HasChildren {
        // catch all for views that have children but don't size specifically themselves, any views with children that do
        // resize themselves should come before that
        let children = view is any InteractivityStateBasedView ? builder.getChildrenForState(view as! any InteractivityStateBasedView) : hc.children
        let largestChildSize = children
            .map({ getRequestedSize($0, builder: builder) })
            .maxSize()
        return largestChildSize
    }
    return .zero
}
