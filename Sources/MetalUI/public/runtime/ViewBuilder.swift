//
//  ViewBuilder.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

@MainActor
@resultBuilder
public struct ViewBuilder {
    public static func buildBlock(_ components: any View...) -> some View {
        Group(components)
    }

    public static func buildOptional(_ component: [any View]?) -> some View {
        Group(component ?? [])
    }

    public static func buildEither(first component: [any View]) -> some View {
        Group(component)
    }

    public static func buildEither(second component: [any View]) -> some View {
        Group(component)
    }
}
