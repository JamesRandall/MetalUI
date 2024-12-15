//
//  StateTracker.swift
//  MetalUI
//
//  Created by James Randall on 14/12/2024.
//

import simd
import CoreGraphics
import Foundation

struct HitResponse {
    var isHit: Bool
    var mouseDown: Bool
}

public class StateTracker {
    private let quadtree : Quadtree
    private var _mousePosition: CGPoint?
    private var _mouseDown : Bool = false
    
    init (size: CGSize) {
        self.quadtree = Quadtree(bounds: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))
    }
    
    func registerInteractiveZone(viewId: UUID, zone: CGRect) {
        let _ = quadtree.insert(Rect(id: viewId, rect: zone))
    }
    
    func isInteractiveZoneHit(viewId: UUID) -> HitResponse {
        guard let mp = _mousePosition else { return HitResponse(isHit: false, mouseDown: _mouseDown) }
        return HitResponse(isHit: quadtree.query(at: mp).contains(where: { $0.id == viewId }), mouseDown: _mouseDown)
    }
    
    public func updateMouseLocation(with: CGPoint) {
        self._mousePosition = with
    }
    
    public func mouseDown() {
        self._mouseDown = true
    }
    
    public func mouseUp() {
        self._mouseDown = false
    }
    
    func reset() {
        quadtree.reset()
    }
}
