//
//  Group.swift
//  MetalUI
//
//  Created by James Randall on 26/12/2024.
//

// The group is used internally to manage children
internal struct Group : View, HasChildren {
    internal let children: [any View]
    
    init (_ components: [any View]) {
        self.children = components
    }
    
    var body: some View {
        return self
    }
}
