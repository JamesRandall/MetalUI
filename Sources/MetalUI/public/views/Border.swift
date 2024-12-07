//
//  Border.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//

/*
struct Border {
    var topColor: simd_float4
    var topWidth: Float
    var leftColor: simd_float4
    var leftWidth: Float
    var rightColor: simd_float4
    var rightWidth: Float
    var bottomColor: simd_float4
    var bottomWidth: Float
    
    func draw(builder: GuiMutater, position: simd_float2, size: simd_float2) {
        let left = position.x - size.x / 2.0
        let right = position.x + size.x / 2.0
        let top = position.y + size.y / 2.0
        let bottom = position.y - size.y / 2.0
        
        builder.rectangle(position: .init(x: left, y: position.y), size: .init(x: leftWidth, y: bottom-top), color: leftColor)
        builder.rectangle(position: .init(x: position.x, y: top), size: .init(x: right-left, y: topWidth), color: topColor)
        builder.rectangle(position: .init(x: right, y: position.y), size: .init(x: rightWidth, y: bottom-top), color: rightColor)
        builder.rectangle(position: .init(x: position.x, y: bottom), size: .init(x: right-left, y: bottomWidth), color: bottomColor)
    }
    
    static let none : Border =
    Border(topColor: simd_float4(1.0,1.0,1.0,0.0), topWidth: 6, leftColor: .zero, leftWidth: 0, rightColor: .zero, rightWidth: 0, bottomColor: .zero, bottomWidth: 0)
}
*/
