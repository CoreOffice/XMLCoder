//
//  NullBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct NullBox {
    init() {}
}

extension NullBox: Box {
    var isNull: Bool {
        return true
    }

    func xmlString() -> String? {
        return nil
    }
}

extension NullBox: SimpleBox {}

extension NullBox: Equatable {
    static func ==(_: NullBox, _: NullBox) -> Bool {
        return true
    }
}

extension NullBox: CustomStringConvertible {
    var description: String {
        return "null"
    }
}
