//
//  DataBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/19/18.
//

import Foundation

struct DataBox: Equatable {
    enum Format: Equatable {
        case base64
    }

    typealias Unboxed = Data

    let unboxed: Unboxed
    let format: Format

    init(_ unboxed: Unboxed, format: Format) {
        self.unboxed = unboxed
        self.format = format
    }

    init?(base64 string: String) {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        self.init(data, format: .base64)
    }

    func unbox() -> Unboxed {
        return unboxed
    }

    func xmlString(format: Format) -> String {
        switch format {
        case .base64:
            return unboxed.base64EncodedString()
        }
    }
}

extension DataBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return xmlString(format: format)
    }
}

extension DataBox: SimpleBox {}

extension DataBox: CustomStringConvertible {
    var description: String {
        return unboxed.description
    }
}
