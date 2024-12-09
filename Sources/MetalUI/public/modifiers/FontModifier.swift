//
//  PositionedView.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

import Combine
import simd

struct FontModifier : View, RequiresRuntimeRef {
    let content : AnyView
    private let nameRef: ValueRef<String>?
    private let sizeRef: ValueRef<Float>?
    var runtimeRef = RuntimeRef()
    
    init (content: AnyView, name: String?, size: Float?) {
        self.content = content
        if let name = name {
            self.nameRef = ValueRef(name)
        }
        else {
            self.nameRef = nil
        }
        if let size = size {
            self.sizeRef = ValueRef(size)
        }
        else {
            self.sizeRef = nil
        }
    }
    
    var body : some View {
        AnyView(self.content)
    }
    
    var size : Float? { sizeRef?.value }
    var name : String? { nameRef?.value }
}

public extension View {
    func font(_ name: String, ofSize: Float?=nil) -> some View {
        FontModifier(content: AnyView(self), name: name, size: ofSize)
    }
    
    func font(ofSize: Float) -> some View {
        FontModifier(content: AnyView(self), name: nil, size: ofSize)
    }
    
    func systemFont(ofSize: Float?) -> some View {
        FontModifier(content: AnyView(self), name: ".SFUI-Regular", size: ofSize)
    }
}
