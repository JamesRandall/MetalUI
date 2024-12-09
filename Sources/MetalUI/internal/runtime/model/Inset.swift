//
//  Inset.swift
//  MetalUI
//
//  Created by James Randall on 09/12/2024.
//

@MainActor
struct Inset {
    var top: Float
    var left: Float
    var bottom: Float
    var right: Float
    
    var horizontal : Float { left + right }
    var vertical : Float { top + bottom }
    
    static let none = Inset(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    func mergeWith(insetDescription: InsetDescription) -> Inset {
        let w = insetDescription.width
        var copy = self
        
        insetDescription.border.forEach({ side in
            if side == .all {
                copy.top = w
                copy.left = w
                copy.bottom = w
                copy.right = w
            } else {
                switch side {
                case .bottom:
                    copy.bottom = w
                case .top:
                    copy.top = w
                case .left:
                    copy.left = w
                case .right:
                    copy.right = w
                default: ()
                }
            }
        })
        return copy
    }
    
    static let zero = Inset(top: 0, left: 0, bottom: 0, right: 0)
}
