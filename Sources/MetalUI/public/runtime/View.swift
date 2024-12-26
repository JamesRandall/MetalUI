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

public protocol HasVariableInstances : View {
    // if the view has a dynamic number of render calls (and therefore instances in the GPU pipeline) then
    // it should be returned here. this allows sufficient space to be reserved in the instance buffer for the
    // maximum draw size of the control
    //
    // its also only required if the control mutates - if a control doesn't mutate then by definition it has a
    // fixed number of render calls
    func maxInstances() -> Int
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

// this interface allows us to only attach the modifiers for state to
// select views
@MainActor
public protocol HasStateTriggeredContent : View {
    
}

// whereas this interface lets the builders access the children from the state

