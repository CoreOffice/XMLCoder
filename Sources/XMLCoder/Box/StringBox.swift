//
//  StringBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal class StringBox {
    typealias Unboxed = String
    
    let unboxed: Unboxed
    
    var xmlString: String {
        return self.unboxed.description
    }
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension StringBox: Equatable {
    static func == (lhs: StringBox, rhs: StringBox) -> Bool {
        return lhs.unboxed == rhs.unboxed
    }
}

extension StringBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
