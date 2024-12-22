//
//  ImageManager.swift
//  MetalUI
//
//  Created by James Randall on 22/12/2024.
//

import Metal

struct TextureImagePack {
    var imagePack: ImagePack
    var texture: MTLTexture
    var textureSlot: Int
}

class ImageManager {
    private var _imagePacks : [String : TextureImagePack]
    
    init(device: MTLDevice, imagePacks: [ImagePack]) {
        self._imagePacks = Dictionary(
            uniqueKeysWithValues: imagePacks.compactMap {
                guard let textureImagePack = ImageManager.createTexturedImagePack(device: device, imagePack: $0) else {
                    return nil
                }
                return ($0.name, textureImagePack)
            }
        )
    }
    
    func getSubImage(name: String, imagePackName: String) -> (SubImage,Int)? {
        guard let imagePack = _imagePacks[imagePackName] else { return nil }
        guard let subImage = imagePack.imagePack.images[name] else { return nil }
        return (subImage, imagePack.textureSlot)
    }
    
    static func createTexturedImagePack(device: MTLDevice, imagePack: ImagePack) -> TextureImagePack? {
        guard let (imageData, width, height) = imagePack.packedImage.toTextureData() else {
            print("Failed to extract image data")
            return nil
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .renderTarget]

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("Failed to create MTLTexture")
            return nil
        }
        
        // Copy the image data into the Metal texture
        let region = MTLRegionMake2D(0, 0, width, height)
        imageData.withUnsafeBytes { rawBufferPointer in
            // Safely use the raw pointer
            let rawPointer: UnsafeRawPointer = rawBufferPointer.baseAddress!
            texture.replace(region: region, mipmapLevel: 0, withBytes: rawPointer, bytesPerRow: bytesPerRow)
        }
        
        return TextureImagePack(imagePack: imagePack, texture: texture, textureSlot: 1)
    }
}
