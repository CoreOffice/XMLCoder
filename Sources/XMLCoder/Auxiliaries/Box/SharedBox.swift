//
//  SharedBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/22/18.
//

import Foundation

class SharedBox<Unboxed: Box> {
    fileprivate var unboxed: Unboxed

    init(_ wrapped: Unboxed) {
        unboxed = wrapped
    }

    func withShared<Result>(_ body: (inout Unboxed) throws -> Result) rethrows -> Result {
        return try body(&unboxed)
    }
}

extension SharedBox: Box {
    var isNull: Bool {
        return unboxed.isNull
    }

    func xmlString() -> String? {
        return unboxed.xmlString()
    }
}

extension SharedBox: SharedBoxProtocol {
    func unbox() -> Unboxed {
        return unboxed
    }
}
