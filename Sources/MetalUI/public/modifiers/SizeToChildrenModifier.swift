//
//  PositionedView.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Combine
import CoreGraphics
import simd

struct SizeToChildrenModifier : View {
    let content : AnyView
    
    init (content: AnyView) {
        self.content = content
    }
    
    init (content: AnyView, binding: Published<simd_float2>.Publisher) {
        self.content = content
    }
    
    var body : some View {
        AnyView(self.content)
    }
}

public extension View {
    func sizeToChildren() -> some View {
        SizeToChildrenModifier(content: AnyView(self))
    }
}
