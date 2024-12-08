//
//  GuiRenderer.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import MetalKit

private let alignedUniformsSize = (MemoryLayout<GuiUniforms>.size + 0xFF) & -0x100
// TODO: this needs to be based on the number of GUI objects
private let maxBuffersInFlight = 256

extension float4x4 {
    init(scaling: SIMD3<Float>) {
        self.init(SIMD4<Float>(scaling.x, 0, 0, 0),
                  SIMD4<Float>(0, scaling.y, 0, 0),
                  SIMD4<Float>(0, 0, scaling.z, 0),
                  SIMD4<Float>(0, 0, 0, 1))
    }
    
    init(translation: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(translation.x, translation.y, translation.z, 1))
    }
}

protocol PrimitiveRenderer {
    func getGameObjectPosition(id: UUID) -> simd_float2;
    func rectangle(position:simd_float2, size: simd_float2, color: simd_float4);
}

public class GuiRenderer {
    private let pipelineState: MTLRenderPipelineState
    private let rectangleVertexBuffer: MTLBuffer
    private let depthStencilState : MTLDepthStencilState
    
    private var uniforms: GuiUniforms
    private var uniformsBuffer: MTLBuffer!
    
    private var projectionMatrix: float4x4 = matrix_identity_float4x4
    
    /*static func listResourcesInBundle() {
        guard let resourcePath = Bundle.module.resourcePath else {
            print("Failed to locate resource path in Bundle.module")
            return
        }

        do {
            let fileManager = FileManager.default
            let resources = try fileManager.contentsOfDirectory(atPath: resourcePath)
            print("Resources in Bundle.module:")
            for resource in resources {
                print(resource)
            }
        } catch {
            print("Error listing resources: \(error)")
        }
    }*/
    
    static func loadShaderLibrary(device: MTLDevice) -> MTLLibrary? {
        //listResourcesInBundle()
        
        guard let shaderURL = Bundle.module.url(forResource: "default", withExtension: "metallib") else {
            print("Failed to find metallib")
            return nil
        }
        do {
            let library = try device.makeLibrary(URL: shaderURL)
            return library
        } catch {
            print("Failed to load Metal library: \(error)")
            return nil
        }
    }
    
    @MainActor
    public init?(device: MTLDevice, metalKitView: MTKView) {
        let library = GuiRenderer.loadShaderLibrary(device: device) //device.makeDefaultLibrary()
        guard
            let vertexFunction = library?.makeFunction(name: "guiVertexShader"),
            let fragmentFunction = library?.makeFunction(name: "guiFragmentShader")
        else { return nil }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilDescriptor.isDepthWriteEnabled = false
        guard let dss = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else { return nil }
        self.depthStencilState = dss
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<GuiVertex>.stride
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex


        // Set up the render pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        //pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        let colorAttachment = pipelineDescriptor.colorAttachments[0]
        colorAttachment?.isBlendingEnabled = true
        colorAttachment?.rgbBlendOperation = .add
        colorAttachment?.alphaBlendOperation = .add
        colorAttachment?.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment?.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        colorAttachment?.pixelFormat = metalKitView.colorPixelFormat
        //pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        //pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        guard let rvb = GuiRenderer.makeRectangleVertexBuffer(device: device) else { return nil }
        self.rectangleVertexBuffer = rvb
        self.uniforms = GuiUniforms(projectionMatrix: matrix_identity_float4x4)
        
        // Create the pipeline state
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Error occurred when creating render pipeline state: \(error)")
            return nil
        }
    }
    
    func updateProjectionMatrix(device: MTLDevice, size: CGSize) {
        let viewWidth = Float(size.width)
        let viewHeight = Float(size.height)
        
        // Define the coordinate system boundaries (e.g., 0 to view width and height)
        let left: Float = 0
        let right: Float = viewWidth
        let bottom: Float = 0
        let top: Float = viewHeight
        // flipping top and bottom in the below shifts the origin from the bottom left to the top left
        self.projectionMatrix = Math3D.orthographicMatrix(left: left, right: right, bottom: top, top: bottom)
        
        self.uniforms = GuiUniforms(projectionMatrix: self.projectionMatrix)
        self.uniformsBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<GuiUniforms>.stride,
            options: []
        )!
    }
    
    @MainActor
    public func draw(in view: MTKView, renderEncoder: MTLRenderCommandEncoder, gui: Runtime, worldProjection: float4x4) {
        guard let device = view.device else { return }
        
        self.updateProjectionMatrix(device: device, size: view.drawableSize) // only do this on init and resize
        
        gui.updateIfRequired(renderEncoder: renderEncoder, worldProjection: worldProjection, size: view.drawableSize.toSimd())
        
        /*gui.applyFrameUpdates(deltaTime: 0.0, worldProjection: worldProjection, gameObjectLocator: game, size: view.drawableSize)*/
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setVertexBuffer(rectangleVertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformsBuffer, offset:0, index: 1)
        renderEncoder.setFragmentTexture(gui.textManager.texture, index: 0)
        
        gui.render(renderEncoder: renderEncoder, worldProjection: self.projectionMatrix, size: view.drawableSize.toSimd())

    }
    
    struct GuiVertex {
        var position: simd_float3
        var texCoord: simd_float2
    }
    
    class func makeRectangleVertexBuffer(device: MTLDevice) -> MTLBuffer? {
        let vertices : [GuiVertex] = [
            GuiVertex(position:simd_float3(0.0, 1.0, 0.0), texCoord:simd_float2(0, 1)), // Top left vertex
            GuiVertex(position:simd_float3(0.0, 0.0, 0.0), texCoord:simd_float2(0, 0)),  // Bottom left vertex
            GuiVertex(position:simd_float3(1.0, 0.0, 0.0), texCoord:simd_float2(1, 0)),   // Bottom right vertex
            GuiVertex(position:simd_float3(0.0, 1.0, 0.0), texCoord:simd_float2(0, 1)), // Top left vertex
            GuiVertex(position:simd_float3(1.0, 1.0, 0.0), texCoord:simd_float2(1, 1)), // Top right vertex
            GuiVertex(position:simd_float3(1.0, 0.0, 0.0), texCoord:simd_float2(1, 0)) // Bottom right vertex
        ]
        
        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: MemoryLayout<GuiVertex>.stride * vertices.count,
                                             options: [])
        
        return vertexBuffer
        
        // Define a simple triangle in normalized device coordinates (NDC)
        /*let vertices = [
            simd_float3(-0.5, 0.5, 0.0), // Top left vertex
            simd_float3(-0.5, -0.5, 0.0),  // Bottom left vertex
            simd_float3(0.5, -0.5, 0.0),   // Bottom right vertex
            simd_float3(-0.5, 0.5, 0.0), // Top left vertex
            simd_float3(0.5, 0.5, 0.0), // Top right vertex
            simd_float3(0.5, -0.5, 0.0),   // Bottom right vertex
        ]

        // Create a vertex buffer
        return device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<simd_float3>.stride * vertices.count,
            options: []
        )*/
    }
}
