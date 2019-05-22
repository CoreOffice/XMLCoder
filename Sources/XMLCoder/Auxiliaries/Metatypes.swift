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

extension Array: AnySequence {}

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
