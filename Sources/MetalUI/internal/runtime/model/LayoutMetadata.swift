//
//  LayoutMetadata.swift
//  starship-tactics
//
//  Created by James Randall on 04/12/2024.
//

import simd

class LayoutMetadata : Equatable {
    var _instanceDataOffset: Int = 0
    var _instanceDataCount: Int = 0
    var _position : simd_float2 = .zero
    var _size : simd_float2 = .zero
    
    init() { }
    
    var instanceDataOffset: Int { _instanceDataOffset }
    var instanceDataCount: Int { _instanceDataCount }
    var position : simd_float2 { _position }
    var size : simd_float2 { _size }
    
    @discardableResult
    func withInstanceData(offset: Int, count: Int) -> LayoutMetadata {
        self._instanceDataOffset = offset
        self._instanceDataCount = count
        return self
    }
    
    @discardableResult
    func with(position: simd_float2) -> LayoutMetadata {
        self._position = position
        return self
    }
    
    @discardableResult
    func with(size: simd_float2) -> LayoutMetadata {
        self._size = size
        return self
    }
    
    static func empty() -> LayoutMetadata { LayoutMetadata() }
    
    // when we compare the structs that contain layout metadata it is excluded from the equality comparison
    // which we do by saying they are always equal
    static func == (lhs: LayoutMetadata, rhs: LayoutMetadata) -> Bool {
        return true
    }
}
