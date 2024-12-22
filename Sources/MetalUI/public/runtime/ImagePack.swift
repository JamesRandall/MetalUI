//
//  ImagePack.swift
//  MetalUI
//
//  Created by James Randall on 22/12/2024.
//

import AppKit

struct SubImage {
    var u: Double
    var v: Double
    var u2: Double
    var v2: Double
    var width: Int
    var height: Int
}

public struct ImagePack {
    var name: String
    var packedImage: NSImage
    var images: [String:SubImage]
    
    public static func loadFromBundle(assetName: String, imagePackName: String = "default") -> ImagePack? {
        guard let imageUrl = Bundle.main.url(forResource: assetName, withExtension: "png") else {
            print("Asset \(assetName).png not found in main bundle")
            return nil
        }
        guard let jsonUrl = Bundle.main.url(forResource: assetName, withExtension: "json") else {
            print("Asset \(assetName).json not found in main bundle")
            return nil
        }
        
        guard let packedImage = NSImage(contentsOf: imageUrl) else { return nil }
        guard let description = PackedImage.load(from:jsonUrl) else { return nil }
        
        var images: [String:SubImage] = [:]
        description.images.forEach {
            let tc = $0.textureCoordinates
            images[$0.name] = SubImage(
                u: tc.u,
                v: tc.v,
                u2: tc.u2,
                v2: tc.v2,
                width: $0.location.width,
                height: $0.location.height)
        }
        
        return ImagePack(name: imagePackName, packedImage: packedImage, images: images)
    }
}
