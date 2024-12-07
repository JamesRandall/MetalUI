//
//  Math.swift
//  eight-bit-golf
//
//  Created by James Randall on 26/08/2024.
//

import Foundation
import simd

extension SIMD4<Float> {
    var xyx : simd_float3 {
        .init(x: x, y: y, z: z)
    }
}

extension [Double] {
    func toSimd4() -> simd_float4 {
        simd_float4(Float(self[0]), Float(self[1]), Float(self[2]), Float(self.count > 3 ? self[3] : 1.0))
    }
}

struct Math3D {
    static let worldUp = simd_float3(0.0, 1.0, 0.0)
    
    static func toRadians(from angle: Float) -> Float {
        return angle * .pi / 180.0;
    }
    
    static func toRadians(from angle: Double) -> Double {
        return angle * .pi / 180.0;
    }
    
    static func createTranslationMatrix(_ from: [Int]) -> simd_float4x4 {
        createTranslationMatrix(from[0], from[1], from[2])
    }
    
    static func createTranslationMatrix(_ from: [Float]) -> simd_float4x4 {
        createTranslationMatrix(from[0], from[1], from[2])
    }
    
    static func createTranslationMatrix(_ tx: Int, _ ty: Int, _ tz: Int) -> simd_float4x4 {
        createTranslationMatrix(Float(tx), Float(ty), Float(tz))
    }
    
    static func createTranslationMatrix(_ tx: Float, _ ty: Float, _ tz: Float) -> simd_float4x4 {
        matrix4x4_translation(tx, ty, tz)
        
        /*return simd_float4x4(rows: [
            simd_float4(1, 0, 0, tx), // First row
            simd_float4(0, 1, 0, ty), // Second row
            simd_float4(0, 0, 1, tz), // Third row
            simd_float4(0, 0, 0, 1)   // Fourth row
        ])*/
    }
    
    static func createViewMatrix(eye: SIMD3<Float>, targetPosition: SIMD3<Float>, upVec: SIMD3<Float>) -> matrix_float4x4 {
        var forward = normalize(eye - targetPosition)
        if forward == simd_float3(0, 0, 0) {
            forward = simd_float3(0, 0, -1) // Default forward direction if eye == targetPosition
        }
        var up = upVec
        if abs(dot(forward, up)) > 0.999 {
            // Choose a fallback up vector orthogonal to forward
            up = abs(forward.y) < 0.999 ? simd_float3(0, 1, 0) : simd_float3(1, 0, 0)
        }
        let right = normalize(cross(up, forward))
        let upAdjusted = cross(forward, right)
        
        let viewMatrix = matrix_float4x4(
            SIMD4<Float>(right.x, upAdjusted.x, -forward.x, 0),
            SIMD4<Float>(right.y, upAdjusted.y, -forward.y, 0),
            SIMD4<Float>(right.z, upAdjusted.z, -forward.z, 0),
            SIMD4<Float>(-dot(right, eye), -dot(upAdjusted, eye), dot(forward, eye), 1)
        )
        
        return viewMatrix
    }
    
    static func createRotationMatrix(angle: Float, axis: simd_float3) -> matrix_float4x4 {
        let normalizedAxis = simd_normalize(axis)
        return matrix_float4x4(simd_quaternion(angle, normalizedAxis))
    }
    
    static func orthographicMatrix(left: Float, right: Float, bottom: Float, top: Float) -> float4x4 {
        let near: Float = -1.0
        let far: Float = 1.0
        
        let tx = -(right + left) / (right - left)
        let ty = -(top + bottom) / (top - bottom)
        let tz = -(far + near) / (far - near)
        
        let matrix = float4x4(columns: (
            SIMD4<Float>(2.0 / (right - left), 0, 0, 0),
            SIMD4<Float>(0, 2.0 / (top - bottom), 0, 0),
            SIMD4<Float>(0, 0, -2.0 / (far - near), 0),
            SIMD4<Float>(tx, ty, tz, 1)
        ))
        
        return matrix
    }
    
    static func createPerspectiveMatrix(fov: Float, size: CGSize, nearPlane: Float, farPlane: Float) -> simd_float4x4 {
        let aspect = Float(size.width / size.height)
        return Math3D.createPerspectiveMatrix(fov: fov, aspectRatio: aspect, nearPlane: nearPlane, farPlane: farPlane)
    }
    
    static func createPerspectiveMatrix(fov: Float, aspectRatio: Float, nearPlane: Float, farPlane: Float) -> simd_float4x4 {
        let tanHalfFov = tan(fov / 2.0)
        let depthScale:Float = 1.0
        
        var matrix = simd_float4x4(0.0)
        matrix[0][0] = 1.0 / (aspectRatio * tanHalfFov)
        matrix[1][1] = 1.0 / (tanHalfFov)
        matrix[2][2] = farPlane / (farPlane - nearPlane) * depthScale
        matrix[2][3] = 1.0
        matrix[3][2] = -(farPlane * nearPlane) / (farPlane - nearPlane) * depthScale
        
        return matrix
    }
    
    static func screenPointToWorldPlane(
        screenPoint: CGPoint,
        screenSize: CGSize,
        viewProjectionMatrix: simd_float4x4
    ) -> simd_float3? {
        // Convert to NDC coordinates
        let xNDC = Float((2.0 * screenPoint.x) / screenSize.width - 1.0)
        let yNDC = Float(1.0 - (2.0 * screenPoint.y) / screenSize.height)

        // Points in NDC space
        let pointNDCNear = simd_float4(xNDC, yNDC, 0.0, 1.0)
        let pointNDCFar = simd_float4(xNDC, yNDC, 1.0, 1.0)

        // Compute inverse View-Projection matrix
        let inverseVPMatrix = simd_inverse(viewProjectionMatrix)

        // Unproject to world space
        let worldPointNear4D = inverseVPMatrix * pointNDCNear
        let worldPointFar4D = inverseVPMatrix * pointNDCFar

        // Convert from homogeneous coordinates
        let worldPointNear = simd_make_float3(worldPointNear4D) / worldPointNear4D.w
        let worldPointFar = simd_make_float3(worldPointFar4D) / worldPointFar4D.w

        // Compute the ray
        let rayOrigin = worldPointNear
        let rayDirection = simd_normalize(worldPointFar - worldPointNear)

        // Ensure the ray is not parallel to the plane y = 0
        guard rayDirection.y != 0 else {
            return nil // No intersection; ray is parallel to the plane
        }

        // Find intersection with the plane y = 0
        let t = -rayOrigin.y / rayDirection.y
        let intersectionPoint = rayOrigin + t * rayDirection

        return simd_float3(intersectionPoint.x, 0.0, intersectionPoint.z)
    }
    
    static func getScreenXY(point: simd_float3, worldProjection: float4x4, size: simd_float2) -> simd_float2 {
        let clipSpacePosition = worldProjection * simd_float4(point, 1.0)
        
        // Perform perspective division to get normalized device coordinates (NDC)
        let ndcX = clipSpacePosition.x / clipSpacePosition.w
        let ndcY = clipSpacePosition.y / clipSpacePosition.w
                
        let screenX = ((ndcX + 1.0) / 2.0) * size.x
        let screenY = ((ndcY + 1.0) / 2.0) * size.y
        
        return simd_float2(screenX, screenY)
    }
}

func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                         vector_float4( 0, ys, 0,   0),
                                         vector_float4( 0,  0, zs, -1),
                                         vector_float4( 0,  0, zs * nearZ, 0)))
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
