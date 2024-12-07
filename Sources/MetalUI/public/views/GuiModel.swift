//
//  Gui.swift
//  starship-tactics
//
//  Created by James Randall on 02/12/2024.
//

import Metal





// we'll rename this
/*class GuiModel {
    private var instanceData: [GuiInstanceData]
    // their is no real point maintaining the array above and we will remove. The canonical version is in instanceBuffer and accessible
    // via a pointer
    private var instanceBuffer : MTLBuffer?
    private var instanceCount: Int { instanceData.count }
    private var mutations: [GuiMutation] = []
    private var rootView : ReferenceView
    private var _attachmentsFromGuiToGameObject: Dictionary<UUID, UUID> = [:]
    
    private init(instanceData: [GuiInstanceData], instanceBuffer: MTLBuffer?, mutations: [GuiMutation], rootView: View, attachmentsFromGuiToGameObject: Dictionary<UUID, UUID>) {
        self.instanceBuffer = instanceBuffer
        self.instanceData = instanceData
        self.mutations = mutations
        self.rootView = ReferenceView(view: rootView)
        self._attachmentsFromGuiToGameObject = attachmentsFromGuiToGameObject
    }
    
    class func empty() -> GuiModel {
        return GuiModel(instanceData: [], instanceBuffer: nil, mutations: [], rootView: Panel {}, attachmentsFromGuiToGameObject: [:])
    }
    
    func applyFrameUpdates(deltaTime: CFTimeInterval, worldProjection: float4x4, gameObjectLocator: GameObjectLocator, size: CGSize) {
        guard let instanceBuffer = self.instanceBuffer else { return }
        
        let updater = GuiUpdater(worldProjection: worldProjection, gameObjectLocator: gameObjectLocator, size: size, instanceBuffer: instanceBuffer, numberOfInstances: self.instanceCount)
        
        walkTree(view: self.rootView.view, action: { v in
            if let gameObjectId = self._attachmentsFromGuiToGameObject[v.id] {
                if let newPosition = updater.getGameObjectPosition(id: gameObjectId) {
                    v.metadata.with(position: newPosition)
                    updater.setBaseInstanceIndex(v.metadata.instanceDataOffset)
                    v.update(builder: updater)
                }
            }
            return true
        })
        
        /*mutations.forEach { mutatorSet in
            mutatorSet.mutations.forEach { mutator in
                let mutationResult = mutator(updater)
                if mutationResult.requiresInstanceUpdate {
                    mutationResult.newView.update(builder: updater)
                }
            }
        }*/
    }
    
    private func walkTree(view: View, action:(View) -> Bool) {
        if action(view) {
            if let contentView = view as? ContentView {
                contentView.children.forEach { walkTree(view: $0, action: action) }
            }
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        guard let instanceBuffer = self.instanceBuffer else { return }
        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 2)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: instanceCount)
    }
    
    class func build(device: MTLDevice, worldProjection: float4x4, gameObjectLocator: GameObjectLocator, size: CGSize, content: () -> View) -> GuiModel? {
        let templateRootView = content()
        let builder = GuiViewBuilderImpl(worldProjection: worldProjection, gameObjectLocator: gameObjectLocator, size: size)
        let constructedRootView = GuiModel.constructInstanceGeometry(builder:builder, view: templateRootView)
        if builder.instanceData.isEmpty { return nil }
        guard let ib = device.makeBuffer(bytes: builder.instanceData, length: MemoryLayout<GuiInstanceData>.stride * builder.instanceData.count, options: .storageModeShared) else { return nil }
        return GuiModel(instanceData: builder.instanceData, instanceBuffer: ib, mutations: builder.mutations, rootView: constructedRootView,
           attachmentsFromGuiToGameObject: builder.attachmentsFromGuiToGameObject)
    }
    
    class func constructInstanceGeometry(builder: GuiViewBuilderImpl, view: View) -> View {
        var constructedView = view
        
        let instanceOffset = builder.instanceData.count
        constructedView.build(builder: builder)
        constructedView.update(builder: builder)
        let instanceCount = builder.instanceData.count - instanceOffset
        constructedView.metadata = view.metadata.withInstanceData(offset: instanceOffset, count: instanceCount)
        if var contentView = constructedView as? ContentView {
            let newChildren = contentView.children.map { child in
                GuiModel.constructInstanceGeometry(builder: builder, view: child)
            }
            contentView.children = newChildren
        }
        
        return constructedView
    }
}*/

//struct ConstructedGui {
//    var instanceData: [GuiInstanceData]
//}

