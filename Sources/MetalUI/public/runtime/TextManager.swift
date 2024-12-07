//
//  TextureManager.swift
//  MetalUI
//
//  Created by James Randall on 07/12/2024.
//

import simd
import CoreGraphics
import Metal
import CoreGraphics

struct MetalText : Hashable {
    var text : String
    var fontName : String
    var color : simd_float4
    var size : CGFloat
}

struct RenderedTextInfo {
    var textureIndex : Int
    var rect : CGRect
}

class TextManager {
    private var _textures : Dictionary<MetalText, RenderedTextInfo> = [:]
    private var _image : CGImage?
    private var _texture : MTLTexture?
    private let _fontProvider : (String,CGFloat) -> NSObject
    private let _scale : CGFloat
    
    init(scale: CGFloat, fontProvider : @escaping (String,CGFloat) -> NSObject) {
        self._scale = scale
        self._fontProvider = fontProvider
    }
    
    func getRenderInfo(device: MTLDevice, text : String, fontName : String, color : simd_float4, size : CGFloat) -> RenderedTextInfo? {
        return getRenderInfo(device: device, metalText: MetalText(text: text, fontName: fontName, color: color, size: size))
    }
    
    func getRenderInfo(device: MTLDevice, metalText : MetalText) -> RenderedTextInfo? {
        if let existingRenderInfo = _textures[metalText] {
            return existingRenderInfo
        }
        
        let textImage = createTextImage(
            text: metalText.text,
            color: CGColor(
                red: CGFloat(metalText.color.x),
                green: CGFloat(metalText.color.y),
                blue: CGFloat(metalText.color.z),
                alpha: CGFloat(metalText.color.w)
            ),
            font: self._fontProvider(metalText.fontName, metalText.size),
            scale: _scale)
        guard let textImage = textImage else { return nil }
        if let image = self._image {
            let combinedImage = combineImages(topImage: image, bottomImage: textImage)
            self._image = combinedImage
            createBuffer(device: device)
            return RenderedTextInfo(textureIndex: 0, rect: CGRectMake(0, CGFloat(image.height-1), CGFloat(textImage.width), CGFloat(textImage.height)))
        }
        
        let renderedTextInfo = RenderedTextInfo(textureIndex: 0, rect: CGRect(origin: .zero, size: CGSizeMake(CGFloat(textImage.width), CGFloat(textImage.height))))
        self._image = textImage
        createBuffer(device: device)
        return renderedTextInfo
    }
    
    private func createBuffer(device: MTLDevice) {
        guard let image = self._image else { return }
        let width = Int(image.width)
        let height = Int(image.height)
        
        // Create a CGContext to extract pixel data from the CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            print("Failed to create CGContext")
            return
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get the raw image data from the context
        guard let imageData = context.data else {
            print("Failed to extract image data")
            return
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .renderTarget]

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("Failed to create MTLTexture")
            return
        }

        // Copy the image data into the Metal texture
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: imageData, bytesPerRow: bytesPerRow)
        self._texture = texture
    }
}

private func createTextImage(text: String, color: CGColor, font: NSObject, scale: CGFloat) -> CGImage? {
    // Create a bitmap context
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let attributedString = NSAttributedString(string: text, attributes: attributes)
    let size = attributedString.size()
    
    let width = Int(size.width * scale)
    let height = Int(size.height * scale)

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        print("Failed to create CGContext")
        return nil
    }

    // Clear the context
    context.setFillColor(CGColor(gray: 0.0, alpha: 0.0))
    context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

    // Draw the text
    
    attributedString.draw(
        with: CGRect(x: 0, y: 0, width: size.width, height: size.height),
        options: .usesLineFragmentOrigin,
        context: nil
    )

    // Create an image from the context
    return context.makeImage()
}

private func combineImages(topImage: CGImage, bottomImage: CGImage) -> CGImage? {
    // Get the dimensions of the images
    let topWidth = topImage.width
    let topHeight = topImage.height
    let bottomWidth = bottomImage.width
    let bottomHeight = bottomImage.height

    // Calculate the width and height of the resulting image
    let combinedWidth = max(topWidth, bottomWidth)
    let combinedHeight = topHeight + bottomHeight

    // Create a color space
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    // Create a CGContext to draw the images
    guard let context = CGContext(
        data: nil,
        width: combinedWidth,
        height: combinedHeight,
        bitsPerComponent: 8,
        bytesPerRow: 4 * combinedWidth,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        print("Failed to create CGContext")
        return nil
    }

    // Draw the top image
    context.draw(topImage, in: CGRect(x: 0, y: bottomHeight, width: topWidth, height: topHeight))

    // Draw the bottom image
    context.draw(bottomImage, in: CGRect(x: 0, y: 0, width: bottomWidth, height: bottomHeight))

    // Create a new CGImage from the context
    return context.makeImage()
}


