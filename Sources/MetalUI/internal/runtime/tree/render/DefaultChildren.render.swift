//
//  DefaultChildren.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

extension RenderTree {
    static func render(hasChildren view: HasChildren, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        builder.resetForChild()
        view.children.forEach({ let _ = renderTree($0, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y ) })
    }
}
