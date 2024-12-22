//
//  PackedImageDescription.swift
//  Sprite Packer
//
//  Created by James Randall on 21/12/2024.
//

import AppKit

struct PackedImage : Codable {
    
    struct ImageLocation : Codable {
        var x: Int
        var y: Int
        var width: Int
        var height: Int
    }
    
    struct TextureCoordinates : Codable {
        var u: Double
        var v: Double
        var u2: Double
        var v2: Double
    }
    
    struct ImageDescription : Codable {
        var name: String
        var location: ImageLocation
        var textureCoordinates: TextureCoordinates
    }
    
    var width: Int
    var height: Int
    var images : [ImageDescription]
    
    static func load(from url: URL) -> PackedImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(PackedImage.self, from: data)
    }
}
