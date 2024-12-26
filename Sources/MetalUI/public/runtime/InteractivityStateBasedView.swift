//
//  HasStateTriggeredChildren.swift
//  MetalUI
//
//  Created by James Randall on 14/12/2024.
//


import Metal
import simd

@MainActor
internal protocol InteractivityStateBasedView {
    var stateTrackingId : UUID { get }
    /*var children : [any View] { get }
    var hoverChildren : [any View] { get }
    var pressedChildren : [any View] { get }*/
    var content : any View { get }
    var hoverContent : (any View)? { get }
    var pressedContent : (any View)? { get }
}
