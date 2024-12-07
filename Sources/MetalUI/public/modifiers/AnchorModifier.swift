//
//  AnchorModifier.swift
//  starship-tactics
//
//  Created by James Randall on 07/12/2024.
//

import Combine

enum HorizontalAnchor {
    case left
    case middle
    case right
}

enum VerticalAnchor {
    case top
    case middle
    case bottom
}

struct Anchor {
    var horizontal : HorizontalAnchor
    var vertical : VerticalAnchor
    
    static let Default = Anchor(horizontal: .middle, vertical: .middle)
}

struct AnchorModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let anchorRef: ValueRef<Anchor>
    private var binding: Published<Anchor>.Publisher?
    private var cancellable: AnyCancellable?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, anchor: Anchor) {
        self.content = content
        self.anchorRef = ValueRef(anchor)
        self.binding = nil
        self.cancellable = nil
    }
    
    init (content: AnyView, binding: Published<Anchor>.Publisher) {
        self.content = content
        self.anchorRef = ValueRef(Anchor.Default)
        self.binding = binding
        self.cancellable = binding.sink { [weak anchorRef, weak runtimeRef] newValue in
            //print("PositionedView: \(newValue)")
            anchorRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var anchor : Anchor { anchorRef.value }
}

extension View {
    func anchor(horizontal: HorizontalAnchor) -> some View {
        AnchorModifier(content: AnyView(self), anchor: Anchor(horizontal: horizontal, vertical: .bottom))
    }
    
    func anchor(vertical: VerticalAnchor) -> some View {
        AnchorModifier(content: AnyView(self), anchor: Anchor(horizontal: .left, vertical: vertical))
    }
    
    func anchor(horizontal: HorizontalAnchor, vertical: VerticalAnchor) -> some View {
        AnchorModifier(content: AnyView(self), anchor: Anchor(horizontal: horizontal, vertical: vertical))
    }
}
