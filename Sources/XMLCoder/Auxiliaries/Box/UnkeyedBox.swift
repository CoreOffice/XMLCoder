//
//  UnkeyedBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/20/18.
//

typealias UnkeyedBox = [Box]

extension Array: Box {
    var isNull: Bool {
        return false
    }

    var xmlString: String? {
        return nil
    }
}
