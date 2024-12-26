//
//  DefaultChildren.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

extension RenderTree {
    static func render(zstack view: ZStack, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        builder.resetForChild()
        let _ = renderTree(view.content, builder: builder, maxWidth: requestedSize.contentZone.x, maxHeight: requestedSize.contentZone.y)
    }
}
