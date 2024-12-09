//
//  RequestedSize.swift
//  MetalUI
//
//  Created by James Randall on 08/12/2024.
//

import simd

extension [simd_float2] {
    func maxSize() -> simd_float2 {
        self.reduce(simd_float2.zero, { m,sz in simd_float2(Swift.max(m.x,sz.x), Swift.max(m.y,sz.y)) })
    }
}

private func constrain(_ size:simd_float2, maxWidth: Float, maxHeight: Float) -> simd_float2 {
    simd_float2(min(size.x, maxWidth), min(size.y, maxHeight))
}

@MainActor
func getRequestedSize<V: View>(_ view: V, builder: GuiViewBuilder, maxWidth: Float, maxHeight: Float) -> simd_float2 {
    if let anyView = view as? AnyView {
        return anyView.boxAction<simd_float2>({ getRequestedSize($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
    }
    
    var properties = ViewProperties.getDefault()
    if let sizeConstraintView = view as? any HasViewProperties {
        properties = sizeConstraintView.properties
    }
    let maxWidth = maxWidth - properties.margin.horizontal
    let maxHeight = maxHeight - properties.margin.horizontal
    
    if !properties.sizeToChildren {
        return simd_float2(maxWidth, maxHeight)
    }
    
    if let text = view as? Text {
        return constrain(builder.getSize(text: text.content, properties: properties), maxWidth: maxWidth, maxHeight: maxHeight)
    }
    else if let vs = view as? VStack {
        let sz = vs.children.reduce(simd_float2(0.0,0.0), { size,child in
            let childSize = getRequestedSize(child, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight )
            return simd_float2(max(size.x, childSize.x), size.y + childSize.y)
        })
        return sz
    }
    else if let arvv = view as? AnyResolvedValueView {
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
    }
    else if let hc = view as? HasChildren {
        // catch all for views that have children but don't size specifically themselves, any views with children that do
        // resize themselves should come before that
        let largestChildSize = hc.children
            .map({ getRequestedSize($0, builder: builder, maxWidth: maxWidth, maxHeight: maxHeight ) })
            .maxSize()
        return largestChildSize
    }
    // failing all else we return the current size on the stack
    return builder.getPropagatingProperties().size ?? .zero
}
