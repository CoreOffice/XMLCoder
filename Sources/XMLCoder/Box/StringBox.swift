//
//  StringBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct StringBox: Equatable {
    typealias Unboxed = String

    let unboxed: Unboxed

    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }

    init(xmlString: Unboxed) {
        self.init(xmlString)
    }

    func unbox() -> Unboxed {
        return unboxed
    }
}

extension StringBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return unboxed.description
    }
}

extension StringBox: SimpleBox {}

extension StringBox: CustomStringConvertible {
    var description: String {
        return unboxed.description
    }
}
