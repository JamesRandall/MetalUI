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
        let content = buildTree(view: panel.content, viewProperties: viewProperties.resetForChild())
        return ZStack(properties: viewProperties, builtContent: content)
    }
    else if let vstack = view as? VStack {
        let builtContent = buildTree(view: vstack.content, viewProperties: viewProperties.resetForChild().withSizeToChildren(horizontal: false, vertical: true))
        return VStack(builtContent: builtContent, spacing: vstack.spacing, properties: viewProperties)
    }
    else if let hstack = view as? HStack {
        let builtContent = buildTree(view: hstack.content, viewProperties: viewProperties.resetForChild().withSizeToChildren(horizontal: false, vertical: true))
        return HStack(builtContent: builtContent, spacing: hstack.spacing, properties: viewProperties)
    }
    else if let button = view as? Button {
        let childProperties = viewProperties.resetForChild()
        let content = buildTree(view: button.content, viewProperties: childProperties)
        var hoverContent: (any View)? = nil
        var pressedContent: (any View)? = nil
        if let hoverModifier = viewProperties.hover {
            let view : any View = hoverModifier.hover
            hoverContent = buildTree(view: view, viewProperties: childProperties)
        }
        if let pressedModifier = viewProperties.pressed {
            let view : any View = pressedModifier.pressed
            pressedContent = buildTree(view: view, viewProperties: childProperties)
        }
    
        return Button(
            properties: viewProperties,
            stateTrackingId: button.stateTrackingId,
            action: button.action,
            builtContent: content,
            buildHoverContent: hoverContent,
            buildPressedContent: pressedContent
        )
    }
    else if let text = view as? Text {
        return Text(text.content, properties: viewProperties)
    }
    else if let image = view as? Image {
        return Image(image.name, imagePack: image.imagePack, properties: viewProperties)
    }
    else if view is Spacer {
        return Spacer()
    }
    else if let group = view as? Group {
        // we don't reset child properties for the group as we want them to propagate
        let builtContent = group.children.map({ buildTree(view: $0, viewProperties: viewProperties) })
        return Group(builtContent)
    }
    // Modifiers
    else if let hoverModifier = view as? HoverModifier {
        newViewProperties = newViewProperties.with(hover: hoverModifier)
    }
    else if let pressedModifier = view as? PressedModifier {
        newViewProperties = newViewProperties.with(pressed: pressedModifier)
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
    else if let sc = view as? SizeToChildrenModifier {
        newViewProperties = newViewProperties.withSizeToChildren(horizontal: sc.horizontal, vertical: sc.vertical)
    }
    else if let vm = view as? VisibilityModifier {
        newViewProperties = newViewProperties.with(visibility: vm.visible)
    }
    
    return buildTree(view: view.body, viewProperties: newViewProperties)
}
