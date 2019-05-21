//
//  Metatypes.swift
//  XMLCoder
//
//  Created by Max Desiatov on 30/12/2018.
//

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
protocol AnySequence {
    init()
}

extension Array: AnySequence {
    static var elementType: Any.Type {
        return Element.self
    }
}

extension Dictionary: AnySequence {}

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
