//
//  Untitled.swift
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

import Metal
import simd

@MainActor
public protocol View {
    associatedtype Body: View
    var body: Self.Body { get }
}

@MainActor
internal protocol HasChildren {
    var children : [any View] { get }
}

extension Never: View {
    @MainActor public var body: Never {
        fatalError("Never should not have a body.")
    }
}

@MainActor
internal protocol HasViewProperties : View {
    var properties : ViewProperties { get set }
}
