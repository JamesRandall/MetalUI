//
//  Text.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

extension RenderTree {
    static func render(text: Text, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        builder.text(text: text.content, properties: properties)
    }
}
