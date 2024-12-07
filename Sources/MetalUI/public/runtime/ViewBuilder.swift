//
//  ViewBuilder.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

@resultBuilder
public struct ViewBuilder {
    public static func buildBlock(_ components: any View...) -> [any View] {
        components
    }

    public static func buildOptional(_ component: [any View]?) -> [any View] {
        component ?? []
    }

    public static func buildEither(first component: [any View]) -> [any View] {
        component
    }

    public static func buildEither(second component: [any View]) -> [any View] {
        component
    }
}
