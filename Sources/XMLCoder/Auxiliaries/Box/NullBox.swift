//
//  NullBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

struct NullBox {}

extension NullBox: Box {
    var isNull: Bool {
        return true
    }

    var xmlString: String? {
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
