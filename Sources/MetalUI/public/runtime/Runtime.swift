//
//  GuiRuntime.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Metal
import MetalKit
import simd

nonisolated(unsafe) var runtime: Runtime?

public class Runtime {
    var rootView : any View
    var notificationHandler : (() -> ()) = { }
    var instanceBuffer : MTLBuffer?
    var instanceCount = -1
    var projectionMatrix : float4x4 = matrix_identity_float4x4
    private var _currentView : (any View)?
    private var _updateRequired = false
    private var _textManager : TextManager
    private var _stateTracker : StateTracker
    
    //private var _builderStack : [View] = []
    
    var textManager : TextManager { _textManager }
    
    public var stateTracker : StateTracker { _stateTracker }
    
    @MainActor
    public init?(view: MTKView, scale:CGFloat, fontProvider: @escaping (String, CGFloat) -> NSObject, rootView : any View) {
        guard let device = view.device else { return nil }
        self.rootView = rootView
        self._textManager = TextManager(device: device, scale: scale, fontProvider: fontProvider)
        self._stateTracker = StateTracker(size: view.bounds.size)
        runtime = self
    }
    
    @MainActor
    func render(renderEncoder: MTLRenderCommandEncoder, worldProjection: float4x4, size: simd_float2) {
        if self.instanceBuffer == nil {
            self.buildRenderData(renderEncoder: renderEncoder, worldProjection: worldProjection, size: size)
        }
        guard let instanceBuffer = self.instanceBuffer else { return }
        if self._updateRequired {
            self._updateRequired = false
        }
        
        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 2)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: instanceCount)
    }
    
    func requestRenderUpdate() {
        self._updateRequired = true
        //var newView = self.rootView.body
    }
    
     
    
    @MainActor
    func updateIfRequired(renderEncoder: MTLRenderCommandEncoder, worldProjection: float4x4, size: simd_float2) {
        self.projectionMatrix = worldProjection
        // TODO: when we tree diff need to rethink this reset
        self._stateTracker.reset()
        self.buildRenderData(renderEncoder: renderEncoder, worldProjection: worldProjection, size: size)
    }
    
    @MainActor
    private func buildRenderData(renderEncoder: MTLRenderCommandEncoder, worldProjection: float4x4, size: simd_float2) {
        self.projectionMatrix = worldProjection
        let builder = GuiViewBuilderImpl(worldProjection: worldProjection, size: size, textManager: _textManager, stateTracker: _stateTracker)
        
        self._currentView = buildTree(view: rootView.body, viewProperties: ViewProperties.getDefault())
        guard let currentView = self._currentView else { return }
        let _ = RenderTree.renderTree(currentView, builder: builder, maxWidth: size.x, maxHeight: size.y)
        //currentView.render(runtime: self, builder: builder)
        if builder.instanceData.isEmpty { return }
        guard let ib = renderEncoder.device.makeBuffer(bytes: builder.instanceData, length: MemoryLayout<GuiInstanceData>.stride * builder.instanceData.count, options: .storageModeShared) else { return }
        self.instanceCount = builder.instanceData.count
        self.instanceBuffer = ib
    }
}


