//
//  Mutable.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//


@propertyWrapper
struct Mutable<TType> where TType : Equatable  {
    private var _previousState : TType
    private var _currentState : TType
    
    init(wrappedValue: TType) {
        self._previousState = wrappedValue
        self._currentState = wrappedValue
    }
    
    var wrappedValue: TType {
        get { _currentState }
        set {
            print("Value changed from \(_previousState) to \(newValue)")
            _currentState = newValue
        }
    }
    
    /*
    func registerMutation(parentView : View) -> GuiMutationFunc {
        { _ in GuiMutationResult(
            requiresInstanceUpdate: self._currentState != self._previousState,
            childrenRebuildRequired: false,
            newView: parentView
        ) }
    }*/
}
