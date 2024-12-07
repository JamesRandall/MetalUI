//
//  RuntimeRef.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

@MainActor
protocol RequiresRuntimeRef {
    var runtimeRef : RuntimeRef { get }
}

@MainActor
class RuntimeRef {
    weak var value: Runtime?
    
    init() { self.value = runtime }
    
    //init(_ value: Gui.Runtime?) { self.value = value }
}
