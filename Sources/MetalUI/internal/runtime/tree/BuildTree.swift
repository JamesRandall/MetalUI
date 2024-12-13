//
//  BuildTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
func buildTree<V: View>(view : V, sizeConstraints: ViewProperties) -> any View{
    if let anyView = view as? AnyView {
        return anyView.boxAction({ buildTree(view: $0, sizeConstraints: sizeConstraints) })
    }
    
    var newSizeConstraints = sizeConstraints

    if let panel = view as? Panel {
        let children = panel.children.map({
            buildTree(view: $0, sizeConstraints: sizeConstraints.resetForChild())
        })
        return Panel(properties: sizeConstraints, builtContent: children)
    }
    else if let vstack = view as? VStack {
        let children = vstack.children.map({
            buildTree(view: $0, sizeConstraints: sizeConstraints.resetForChild().with(sizeToChildren: true))
        })
        return VStack(builtContent: children, properties: sizeConstraints)
    }
    else if let text = view as? Text {
        return Text(text.content, properties: sizeConstraints)
    }
    else if let pv = view as? PositionModifier {
        newSizeConstraints = newSizeConstraints.with(position: pv.position, translation: pv.translation)
    }
    else if let mm = view as? MarginModifier {
        newSizeConstraints = newSizeConstraints.mergeMarginWith(insetDescription: mm.margin)
    }
    else if let sv = view as? SizeModifier {
        newSizeConstraints = newSizeConstraints.with(size: sv.size)
    }
    else if let fv = view as? FontModifier {
        if let name = fv.name {
            newSizeConstraints = newSizeConstraints.with(fontName: name)
        }
        if let size = fv.size {
            newSizeConstraints = newSizeConstraints.with(fontSize: size)
        }
    }
    else if let pv = view as? PaddingModifier {
        newSizeConstraints = newSizeConstraints.mergePaddingWith(insetDescription: pv.padding)
    }
    else if let bv = view as? BackgroundModifier {
        newSizeConstraints = newSizeConstraints.with(backgroundColor: bv.background)
    }
    else if let fv = view as? ForegroundColorModifier {
        newSizeConstraints = newSizeConstraints.with(foregroundColor: fv.foreground)
    }
    else if let b = view as? BorderModifier {
        newSizeConstraints = newSizeConstraints.mergeBorderWith(borderDescription: b.border)
    }
    else if view is SizeToChildrenModifier {
        newSizeConstraints = newSizeConstraints.with(sizeToChildren: true)
    }
    else if let vm = view as? VisibilityModifier {
        newSizeConstraints = newSizeConstraints.with(visibility: vm.visible)
    }
    
    return buildTree(view: view.body, sizeConstraints: newSizeConstraints)
}
