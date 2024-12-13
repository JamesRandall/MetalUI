//
//  VisibilityModifier.swift
//  MetalUI
//
//  Created by James Randall on 13/12/2024.
//

import Combine
import CoreGraphics
import simd


// Although we can use conditional login in MetalUI views its not always optimal as it can result in a resize
// (which means a reallocation) of the instance buffer. Using the visibility modifier will hide things without
// requiring this.
struct VisibilityModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let visibleRef: ValueRef<Bool>
    private var binding: Published<Bool>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, visibility: Bool) {
        self.content = content
        self.visibleRef = ValueRef(visibility)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<Bool>.Publisher) {
        self.content = content
        self.visibleRef = ValueRef(true)
        self.binding = binding
        self.cancellable = binding.sink { [weak visibleRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            visibleRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var visible : Bool { visibleRef.value }
}

public extension View {
    
    func visible(_ visibility: Bool) -> some View {
        VisibilityModifier(content: AnyView(self), visibility: visibility)
    }
    
    func size(_ binding:Published<Bool>.Publisher) -> some View {
        VisibilityModifier(content: AnyView(self), binding: binding)
    }
}
