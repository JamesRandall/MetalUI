//
//  BuildTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

/*struct BuildTreeModifiers {
    var sizeToChildren : Bool
    
    func with(sizeToChildren: Bool) -> BuildTreeModifiers {
        var copy = self
        copy.sizeToChildren = false
        return copy
    }
    
    func resetForChild() -> BuildTreeModifiers {
        var copy = self
        copy.sizeToChildren = false
        return copy
    }
    
    static let startingConstraints = BuildTreeModifiers(sizeToChildren: false)
}*/

// = BuildTreeSizeConstraints.startingConstraints
@MainActor
func buildTree<V: View>(view : V, sizeConstraints: ViewProperties) -> any View{
    if let anyView = view as? AnyView {
        return anyView.boxAction({ buildTree(view: $0, sizeConstraints: sizeConstraints) })
    }
    
    /*var view : any View = view
    if var propertyView = view as? any HasViewProperties {
        var properties = propertyView.properties
        properties = properties
            .with(sizeToChildren: sizeConstraints.sizeToChildren)
            .with(backgroundColor: sizeConstraints.backgroundColor)
            .with(position: sizeConstraints.position)
        propertyView.properties = properties
        view = propertyView
    }*/
    
    var newSizeConstraints = sizeConstraints

    if let panel = view as? Panel {
        let children = panel.children.map({
            AnyView(buildTree(view: $0, sizeConstraints: sizeConstraints.resetForChild()))
        })
        return Panel(properties: sizeConstraints, builtContent: children)
    }
    else if let panel = view as? VStack {
        let children = panel.children.map({
            AnyView(buildTree(view: $0, sizeConstraints: sizeConstraints.resetForChild()))
        })
        return VStack(builtContent: children)
    }
    else if let text = view as? Text {
        return Text(text.content, properties: sizeConstraints)
    }
    else if let pv = view as? PositionModifier {
        newSizeConstraints = newSizeConstraints.with(position: pv.position)
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
        let pvContent = buildTree(view: pv.content, sizeConstraints: sizeConstraints.resetForChild())
        return pvContent
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
    
    return buildTree(view: view.body, sizeConstraints: newSizeConstraints)
}
