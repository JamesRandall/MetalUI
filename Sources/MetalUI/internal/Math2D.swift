//
//  Math2D 2.swift
//  eight-bit-golf
//
//  Created by James Randall on 21/10/2024.
//

import Foundation
import simd
import CoreGraphics

extension CGSize {
    func toSimd() -> simd_float2 { simd_float2(Float(self.width), Float(self.height))}
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

struct Math2D {
    static func doLinesIntersect(line1: [CGPoint], line2: [CGPoint]) -> Bool {
        return doLinesIntersect(p1: line1[0], q1: line1[1], p2: line2[0], q2: line2[1])
    }
    
    static func doLinesIntersect(p1: CGPoint, q1: CGPoint, p2: CGPoint, q2: CGPoint) -> Bool {
        func orientation(p: CGPoint, q: CGPoint, r: CGPoint) -> Int {
            let val = (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x)
            
            //let val = (q.y - p.y) * (r.x - p.x) - (q.x - p.x) * (r.y - p.y)
            if abs(val) < .ulpOfOne {
                return 0  // Colinear
            }
            return (val > 0) ? 1 : 2
        }
        
        func onSegment(p: CGPoint, q: CGPoint, r: CGPoint) -> Bool {
            let minX = min(p.x, r.x) - .ulpOfOne
            let maxX = max(p.x, r.x) + .ulpOfOne
            let minY = min(p.y, r.y) - .ulpOfOne
            let maxY = max(p.y, r.y) + .ulpOfOne

            return q.x >= minX && q.x <= maxX && q.y >= minY && q.y <= maxY
        }
        
        let o1 = orientation(p: p1, q: q1, r: p2)
        let o2 = orientation(p: p1, q: q1, r: q2)
        let o3 = orientation(p: p2, q: q2, r: p1)
        let o4 = orientation(p: p2, q: q2, r: q1)

        // General case: If the orientations are different, the segments intersect
        if o1 != o2 && o3 != o4 {
            return true
        }

        // Special cases
        if o1 == 0 && onSegment(p: p1, q: p2, r: q1) { return true }
        if o2 == 0 && onSegment(p: p1, q: q2, r: q1) { return true }
        if o3 == 0 && onSegment(p: p2, q: p1, r: q2) { return true }
        if o4 == 0 && onSegment(p: p2, q: q1, r: q2) { return true }

        return false
    }
    
    static func isPointInPolygon(point: simd_float2, polygon: [simd_float2]) -> Bool {
        let count = polygon.count
        if count < 3 { return false } // A polygon must have at least 3 vertices

        var isInside = false

        var j = count - 1 // Previous vertex index
        for i in 0..<count {
            let vi = polygon[i]
            let vj = polygon[j]

            // Check if the point is within the y-range of the edge
            if (vi.y > point.y) != (vj.y > point.y) {
                // Compute the x-coordinate of the intersection of the ray with the polygon edge
                let intersectionX = (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x
                // Check if the point is to the left of the edge
                if point.x < intersectionX {
                    isInside.toggle()
                }
            }
            j = i // Move to next edge
        }

        return isInside
    }
    
    static func isPointInCircle(point: simd_float2, center: simd_float2, radius: Float) -> Bool {
        simd_length(center - point) <= radius
    }
    
    static func bounds(vertices: [simd_float2]) -> CGRect {
        return bounds(vertices: vertices.map({CGPointMake(CGFloat($0.x), CGFloat($0.y))}))
    }
    
    static func bounds(vertices: [simd_float3]) -> CGRect {
        return bounds(vertices: vertices.map({CGPointMake(CGFloat($0.x), CGFloat($0.z))}))
    }
    
    static func bounds(vertices: [CGPoint]) -> CGRect {
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        
        vertices.forEach({ v in
            minX = min(v.x, minX)
            minY = min(v.y, minY)
            maxX = max(v.x, maxX)
            maxY = max(v.y, maxY)
        })
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    static func distance(_ pt1: CGPoint, _ pt2: CGPoint) -> CGFloat {
        let deltaX = pt2.x-pt1.x
        let deltaY = pt2.y-pt1.y
        
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    static func midpoint(_ pt1: CGPoint, _ pt2: CGPoint) -> CGPoint {
        let minX = min(pt1.x, pt2.x)
        let minY = min(pt1.y, pt2.y)
        let maxX = max(pt1.x, pt2.x)
        let maxY = max(pt1.y, pt2.y)
        let width = maxX - minX
        let height = maxY - minY
        
        return CGPointMake(minX + width/2.0, minY + height/2.0)
    }
    
    static func expandPath(vertices: [CGPoint], by pixels: CGFloat) -> [CGPoint] {
        guard !vertices.isEmpty else { return [] }
        
        // Calculate centroid of the path
        let centroid = vertices.reduce(CGPoint.zero) { $0 + $1 } / CGFloat(vertices.count)
        
        // Expand each vertex
        let expandedVertices = vertices.map { vertex -> CGPoint in
            // Create a vector from the centroid to the vertex
            let vector = CGPoint(x: vertex.x - centroid.x, y: vertex.y - centroid.y)
            let length = hypot(vector.x, vector.y)
            
            // Normalize the vector and scale by the desired expansion
            let scale = (length + pixels) / length
            return CGPoint(x: centroid.x + vector.x * scale, y: centroid.y + vector.y * scale)
        }
        
        return expandedVertices
    }
    
    static func isPointInsideTriangle(triangle: [CGPoint], point: CGPoint) -> Bool {
        guard triangle.count == 3 else {
            fatalError("The triangle must have exactly 3 points.")
        }
        
        let p0 = triangle[0]
        let p1 = triangle[1]
        let p2 = triangle[2]
        
        // Vectors from the triangle vertices to the point
        let v0 = CGPoint(x: p2.x - p0.x, y: p2.y - p0.y)
        let v1 = CGPoint(x: p1.x - p0.x, y: p1.y - p0.y)
        let v2 = CGPoint(x: point.x - p0.x, y: point.y - p0.y)
        
        // Compute dot products
        let dot00 = v0.x * v0.x + v0.y * v0.y
        let dot01 = v0.x * v1.x + v0.y * v1.y
        let dot02 = v0.x * v2.x + v0.y * v2.y
        let dot11 = v1.x * v1.x + v1.y * v1.y
        let dot12 = v1.x * v2.x + v1.y * v2.y
        
        // Compute barycentric coordinates
        let denominator = dot00 * dot11 - dot01 * dot01
        guard denominator != 0 else {
            return false // Triangle is degenerate (has no area)
        }
        
        let u = (dot11 * dot02 - dot01 * dot12) / denominator
        let v = (dot00 * dot12 - dot01 * dot02) / denominator
        
        // Check if point is inside the triangle
        return u >= 0 && v >= 0 && (u + v) <= 1
    }
    
    /// position: The current position relative to the circle's center (simd_float2).
    /// radius: The radius of the circle.
    /// period: The time to complete one loop (T).
    static func circularVelocity(position: simd_float2, radius: Float, period: Float) -> simd_float2 {
        // Angular velocity (omega)
        let omega = 2.0 * Float.pi / period

        // Current position relative to the center
        let x = position.x
        let y = position.y

        // Tangent direction (perpendicular to position)
        let tangentDirection = simd_float2(-y, x) / radius

        // Speed (magnitude of the velocity)
        let speed = omega * radius

        // Velocity vector
        return tangentDirection * speed
    }
}
