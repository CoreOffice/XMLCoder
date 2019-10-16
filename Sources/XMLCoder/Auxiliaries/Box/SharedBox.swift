//
//  SharedBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/22/18.
//

class SharedBox<Unboxed: Box> {
    private(set) var unboxed: Unboxed

    init(_ wrapped: Unboxed) {
        unboxed = wrapped
    }

    func withShared<T>(_ body: (inout Unboxed) throws -> T) rethrows -> T {
        return try body(&unboxed)
    }
}

extension SharedBox: Box {
    var isNull: Bool {
        return unboxed.isNull
    }

    var xmlString: String? {
        return unboxed.xmlString
    }
}

extension SharedBox: SharedBoxProtocol {
    func unbox() -> Unboxed {
        return unboxed
    }
}
