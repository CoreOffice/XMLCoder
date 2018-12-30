//
//  Metatypes.swift
//  XMLCoder
//
//  Created by Max Desiatov on 30/12/2018.
//

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
protocol AnyEmptySequence {
    init()
}

protocol AnyArray {
    static var elementType: Any.Type { get }
}

extension Array: AnyEmptySequence, AnyArray {
    static var elementType: Any.Type {
        return Element.self
    }
}

extension Dictionary: AnyEmptySequence {}

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
protocol AnyOptional {
    init()
}

extension Optional: AnyOptional {
    init() {
        self = nil
    }
}
