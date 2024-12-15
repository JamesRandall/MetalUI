//
//  HasStateTriggeredChildren.swift
//  MetalUI
//
//  Created by James Randall on 14/12/2024.
//


import Metal
import simd

internal protocol HasStateTriggeredChildren : HasChildren {
    var stateTrackingId : UUID { get }
    var children : [any View] { get }
    var hoverChildren : [any View] { get }
    var pressedChildren : [any View] { get }
}
