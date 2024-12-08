//
//  BuildTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
func buildTree<V: View>(view : V) -> any View{
    if let anyView = view as? AnyView {
        return anyView.boxAction({ buildTree(view: $0) })
    }

    if let panel = view as? Panel {
        let children = panel.children.map({
            ActionView(content: AnyView(buildTree(view: $0)), apply: { builder in builder.resetForChild() })
        })
        return Panel(builtContent: children)
    }
    else if let panel = view as? VStack {
        let children = panel.children.map({
            ActionView(content: AnyView(buildTree(view: $0)), apply: { builder in builder.resetForChild() })
        })
        return VStack(builtContent: children)
    }
    else if let text = view as? Text {
        return text
    }
    else if let pv = view as? PositionModifier {
        let pvContent = buildTree(view: pv.content)
        let resolvedPosition = pv.translation(pv.position)
        return ResolvedValueView<simd_float2>(content: AnyView(pvContent), value: resolvedPosition, apply: { value,builder in
            builder.pushLayout(position: value)
        })
    }
    else if let sv = view as? SizeModifier {
        let svContent = buildTree(view: sv.content)
        return ResolvedValueView<simd_float2>(content: AnyView(svContent), value: sv.size, apply: { value,builder in
            builder.pushLayout(size: value)
        })
    }
    else if let fv = view as? FontModifier {
        let fvContent = buildTree(view: fv.content)
        return ResolvedValueView<(String?,Float?)>(content: AnyView(fvContent), value: (fv.name,fv.size), apply: { value,builder in
            if let name = value.0 {
                builder.pushLayout(fontName: name)
            }
            if let size = value.1 {
                builder.pushLayout(fontSize: size)
            }
        })
    }
    else if let bv = view as? BackgroundModifier {
        let bvContent = buildTree(view: bv.content)
        return ResolvedValueView<simd_float4>(content: AnyView(bvContent), value: bv.background, apply: { value,builder in
            builder.mergeProperty(backgroundColor: value)
        })
    }
    else if let bv = view as? ForegroundColorModifier {
        let bvContent = buildTree(view: bv.content)
        return ResolvedValueView<simd_float4>(content: AnyView(bvContent), value: bv.foreground, apply: { value,builder in
            builder.mergeProperty(foregroundColor: value)
        })
    }
    else if let b = view as? BorderModifier {
        let bContent = buildTree(view: b.content)
        return ResolvedValueView<BorderDescription>(content: AnyView(bContent), value: b.border, apply: { value,builder in
            builder.mergeProperty(border: value)
        })
    }
    else if let sc = view as? SizeToChildrenModifier {
        let scContent = buildTree(view: sc.content)
        return ResolvedValueView<Bool>(content: AnyView(scContent), value: true, apply: { _,builder in
            builder.pushLayout(autoSizeMode: .toChildren)
        })
    }

    return buildTree(view: view.body)
}
