//
//  Binding.swift
//  starship-tactics
//
//  Created by James Randall on 05/12/2024.
//

@propertyWrapper
struct Binding<TValue> where TValue : Equatable {
    private var _notificationHandler: (() -> ())?
    private var _storedValue : TValue
    
    init(wrappedValue: TValue, notificationHandler: (() -> ())? = nil) {
        self._storedValue = wrappedValue
        self._notificationHandler = notificationHandler ?? runtime?.notificationHandler ?? { }
    }
    
    var wrappedValue: TValue {
        get {
            return _storedValue
        }
        set {
            if _storedValue != newValue {
                _storedValue = newValue
                _notificationHandler?()
            }
        }
    }
    
}
