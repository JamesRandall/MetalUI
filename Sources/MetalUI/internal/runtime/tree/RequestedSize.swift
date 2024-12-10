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
        return SizeInformation(footprint: size, content: size)
    }
}

private func constrain(_ size:simd_float2, maxWidth: Float, maxHeight: Float) -> simd_float2 {
    simd_float2(min(size.x, maxWidth), min(size.y, maxHeight))
}

struct SizeInformation {
    var footprint: simd_float2
    var content: simd_float2
    
    static let zero = SizeInformation(footprint: .zero, content: .zero)
}

@MainActor
func getRequestedSize<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) -> SizeInformation {
    if let anyView = view as? AnyView {
        return anyView.boxAction<simd_float2>({ getRequestedSize($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
    }
    
    var properties = ViewProperties.getDefault()
    if let sizeConstraintView = view as? any HasViewProperties {
        properties = sizeConstraintView.properties
    }
    let margin = simd_float2(properties.margin.horizontal, properties.margin.vertical)
    if let absoluteSize = properties.size {
        return SizeInformation(
            footprint: absoluteSize + margin,
            content: absoluteSize
        )
    }
    
    let maxWidth = maxWidth - properties.margin.horizontal
    let maxHeight = maxHeight - properties.margin.horizontal
    
    if !properties.sizeToChildren {
        return SizeInformation(
            footprint: simd_float2(maxWidth, maxHeight),
            content: simd_float2(maxWidth, maxHeight) - margin
        )
    }
    
    if let text = view as? Text {
        let textSize = constrain(builder.getSize(text: text.content, properties: properties), maxWidth: maxWidth, maxHeight: maxHeight)
        return SizeInformation(
            footprint: textSize + margin,
            content: textSize
        )
    }
    else if let vs = view as? VStack {
        let content = vs.children.reduce(simd_float2(0.0,0.0), { sz,child in
            let childSize = getRequestedSize(child, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight - sz.y)
            return simd_float2(max(childSize.footprint.x, sz.x), sz.y + childSize.footprint.y)
        })
        
        return SizeInformation(
            footprint: content + margin,
            content: content
        )
    }
    /*else if let arvv = view as? AnyResolvedValueView {
        //arvv.applyValue(with: builder)
        if arvv.layoutType == .size {
            if let sizeView = arvv as? ResolvedValueView<simd_float2> {
                return sizeView.value
            }
            else {
                fatalError("This should not be possible")
            }
        }
        return getRequestedSize(arvv.content, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight )
    }
    else if let av = view as? ActionView {
        return getRequestedSize(av.content, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight )
    }*/
    else if let hc = view as? HasChildren {
        // catch all for views that have children but don't size specifically themselves, any views with children that do
        // resize themselves should come before that
        let largestChildSize = hc.children
            .map({ getRequestedSize($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
            .maxSize()
        return largestChildSize
    }
    // failing all else we return the current size on the stack
    return .zero
}
