//
//  Text.render.swift
//  MetalUI
//
//  Created by James Randall on 17/12/2024.
//

extension RenderTree {
    static func render(image: Image, requestedSize: SizeInformation, properties: ViewProperties, builder: GuiViewBuilder) {
        builder.image(name: image.name, imagePack: image.imagePack, properties: properties, size: requestedSize.contentZone)
    }
}
