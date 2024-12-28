//
//  AnyView.swift
//  starship-tactics
//
//  Created by James Randall on 06/12/2024.
//

@MainActor
private class _AnyViewBoxBase {
    func typeErasedBody() -> AnyView {
        fatalError("This method must be overridden")
    }
    
    @discardableResult
    func boxAction(_ action: (any View) -> any View) -> any View {
        fatalError("This method must be overridden")
    }
    
    @discardableResult
    func boxAction<TValue>(_ action: (any View) -> TValue) -> TValue {
        fatalError("This method must be overridden")
    }
}

@MainActor
// Concrete box wrapping a specific View
private final class _AnyViewBox<V: View>: _AnyViewBoxBase {
    let content: V
    
    init(_ content: V) {
        self.content = content
    }
    
    override func typeErasedBody() -> AnyView {
        // Wrap the content in AnyView to erase its type
        return AnyView(content)
    }
    
    @discardableResult
    override func boxAction(_ action: (any View) -> any View) -> any View {
        action(content)
    }
    
    override func boxAction<TValue>(_ action: (any View) -> TValue) -> TValue {
        action(content)
    }
}

public struct AnyView: View {
    private let box: _AnyViewBoxBase
    
    public init<V: View>(_ view: V) {
        self.box = _AnyViewBox(view)
    }
    
    func boxAction(_ action: (any View) -> any View) -> any View {
        self.box.boxAction(action)
    }
    
    func boxAction(_ action: (any View) -> ()) {
        self.box.boxAction({ v in
            action(v)
            return v
        })
    }
    
    func boxAction<TValue>(_ action: (any View) -> TValue) -> TValue {
        self.box.boxAction<TValue>(action)
    }
    
    public var body: some View {
        // Here we return `some View` by just returning `AnyView` itself.
        // Because AnyView is a concrete type conforming to View, this is allowed.
        box.typeErasedBody()
    }
}
