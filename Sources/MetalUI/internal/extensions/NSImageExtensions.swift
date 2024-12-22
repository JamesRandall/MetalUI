//
//  NSImageExtensions.swift
//  MetalUI
//
//  Created by James Randall on 22/12/2024.
//

import AppKit

extension NSImage {
    func toTextureData() -> (data: Data, width: Int, height: Int)? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            print("Failed to get bitmap representation")
            return nil
        }
        
        // Ensure the image is in a suitable format (e.g., RGBA)
        guard let cgImage = bitmapRep.cgImage else {
            print("Failed to convert NSBitmapImageRep to CGImage")
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Create a CGContext to extract raw pixel data
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: 8,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpace,
                                       bitmapInfo: bitmapInfo) else {
            print("Failed to create CGContext")
            return nil
        }
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let data = context.data else {
            print("Failed to get raw pixel data")
            return nil
        }
        
        // Return raw pixel data as a Swift Data object
        let dataBuffer = Data(bytes: data, count: bytesPerRow * height)
        return (data: dataBuffer, width: width, height: height)
    }
}
