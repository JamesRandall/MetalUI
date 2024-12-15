//
//  BuildTree.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

import simd

@MainActor
func buildTree<V: View>(view : V, viewProperties: ViewProperties) -> any View{
    if let anyView = view as? AnyView {
        return anyView.boxAction({ buildTree(view: $0, viewProperties: viewProperties) })
    }
    
    var newViewProperties = viewProperties

    if let panel = view as? ZStack {
        let children = panel.children.map({
            buildTree(view: $0, viewProperties: viewProperties.resetForChild())
        })
        return ZStack(properties: viewProperties, builtContent: children)
    }
    else if let vstack = view as? VStack {
        let children = vstack.children.map({
            buildTree(view: $0, viewProperties: viewProperties.resetForChild().with(sizeToChildren: true))
        })
        return VStack(builtContent: children, properties: viewProperties)
    }
    else if let button = view as? Button {
        let childProperties = viewProperties.resetForChild().with(sizeToChildren: true)
        let children = button.children.map({
            buildTree(view: $0, viewProperties: childProperties)
        })
        var hoverChildren: [any View] = []
        var pressedChildren: [any View] = []
        if let hoverModifier = viewProperties.hover {
            hoverChildren = hoverModifier.hover.map({
                buildTree(view: $0, viewProperties: childProperties)
            })
        }
        if let pressedModifier = viewProperties.pressed {
            pressedChildren = pressedModifier.pressed.map({
                buildTree(view: $0, viewProperties: childProperties)
            })
        }
    
        return Button(
            properties: viewProperties,
            stateTrackingId: button.stateTrackingId,
            action: button.action,
            builtContent: children,
            buildHoverContent: hoverChildren,
            buildPressedContent: pressedChildren
        )
    }
    else if let hoverModifier = view as? HoverModifier {
        newViewProperties = newViewProperties.with(hover: hoverModifier)
    }
    else if let pressedModifier = view as? PressedModifier {
        newViewProperties = newViewProperties.with(pressed: pressedModifier)
    }
    else if let text = view as? Text {
        return Text(text.content, properties: viewProperties)
    }
    else if let pv = view as? PositionModifier {
        newViewProperties = newViewProperties.with(position: pv.position, translation: pv.translation)
    }
    else if let mm = view as? MarginModifier {
        newViewProperties = newViewProperties.mergeMarginWith(insetDescription: mm.margin)
    }
    else if let sv = view as? SizeModifier {
        newViewProperties = newViewProperties.with(size: sv.size)
    }
    else if let fv = view as? FontModifier {
        if let name = fv.name {
            newViewProperties = newViewProperties.with(fontName: name)
        }
        if let size = fv.size {
            newViewProperties = newViewProperties.with(fontSize: size)
        }
    }
    else if let pv = view as? PaddingModifier {
        newViewProperties = newViewProperties.mergePaddingWith(insetDescription: pv.padding)
    }
    else if let bv = view as? BackgroundModifier {
        newViewProperties = newViewProperties.with(backgroundColor: bv.background)
    }
    else if let fv = view as? ForegroundColorModifier {
        newViewProperties = newViewProperties.with(foregroundColor: fv.foreground)
    }
    else if let b = view as? BorderModifier {
        newViewProperties = newViewProperties.mergeBorderWith(borderDescription: b.border)
    }
    else if view is SizeToChildrenModifier {
        newViewProperties = newViewProperties.with(sizeToChildren: true)
    }
    else if let vm = view as? VisibilityModifier {
        newViewProperties = newViewProperties.with(visibility: vm.visible)
    }
    
    return buildTree(view: view.body, viewProperties: newViewProperties)
}
