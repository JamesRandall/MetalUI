//
//  Quadtree.swift
//  MetalUI
//
//  Created by James Randall on 14/12/2024.
//

import CoreGraphics
import Foundation

struct Rect {
    let id: UUID
    let rect: CGRect
}

// Quadtree Node
class Quadtree {
    private var bounds: CGRect
    private let capacity: Int
    private var objects: [Rect] = []
    private var subdivisions: [Quadtree]? = nil
    
    init(bounds: CGRect, capacity: Int = 4) {
        self.bounds = bounds
        self.capacity = capacity
    }
    
    func reset() {
        self.objects.removeAll()
        self.subdivisions = nil
    }
    
    // Insert a rectangle into the quadtree
    func insert(_ rect: Rect) -> Bool {
        guard bounds.intersects(rect.rect) else { return false }
        
        // Add to this node if there's capacity and no subdivisions
        if objects.count < capacity && subdivisions == nil {
            objects.append(rect)
            return true
        }
        
        // If capacity is exceeded, subdivide if needed
        if subdivisions == nil {
            subdivide()
        }
        
        // Try inserting into a child node
        for child in subdivisions! {
            if child.insert(rect) {
                return true
            }
        }
        
        return false
    }
    
    // Query for all rectangles containing a point
    func query(at point: CGPoint) -> [Rect] {
        guard bounds.contains(point) else { return [] }
        
        var found: [Rect] = []
        
        // Check objects in this node
        for rect in objects {
            if rect.rect.contains(point) {
                found.append(rect)
            }
        }
        
        // Check child nodes if they exist
        if let subdivisions = subdivisions {
            for child in subdivisions {
                found.append(contentsOf: child.query(at: point))
            }
        }
        
        return found
    }
    
    // Subdivide this node into four quadrants
    private func subdivide() {
        let halfWidth = bounds.width / 2
        let halfHeight = bounds.height / 2
        
        let nw = CGRect(x: bounds.minX, y: bounds.minY, width: halfWidth, height: halfHeight)
        let ne = CGRect(x: bounds.midX, y: bounds.minY, width: halfWidth, height: halfHeight)
        let sw = CGRect(x: bounds.minX, y: bounds.midY, width: halfWidth, height: halfHeight)
        let se = CGRect(x: bounds.midX, y: bounds.midY, width: halfWidth, height: halfHeight)
        
        subdivisions = [
            Quadtree(bounds: nw, capacity: capacity),
            Quadtree(bounds: ne, capacity: capacity),
            Quadtree(bounds: sw, capacity: capacity),
            Quadtree(bounds: se, capacity: capacity)
        ]
    }
}
