//
//  ViewMetadata.swift
//  starship-tactics
//
//  Created by James Randall on 04/12/2024.
//

@propertyWrapper
class ViewMetadata<TType> where TType : Equatable  {
    private var _wrappedValue : TType
    
    init(wrappedValue: TType) {
        self._wrappedValue = wrappedValue
    }
    
    var wrappedValue: TType {
        get { _wrappedValue }
        set {
            _wrappedValue = newValue
        }
    }
}


