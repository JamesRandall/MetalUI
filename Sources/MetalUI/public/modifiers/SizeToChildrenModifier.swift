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
    let horizontal: Bool
    let vertical: Bool
    
    init (content: AnyView, horizontal: Bool, vertical: Bool) {
        self.content = content
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    //init (content: AnyView, binding: Published<simd_float2>.Publisher) {
    //    self.content = content
    //}
    
    var body : some View {
        AnyView(self.content)
    }
}

public extension View {
    func sizeToChildren(horizontal: Bool = true, vertical: Bool = true) -> some View {
        SizeToChildrenModifier(content: AnyView(self), horizontal: horizontal, vertical: vertical)
    }
}
