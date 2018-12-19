//
//  UIntBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct UIntBox: Equatable {
    typealias Unboxed = UInt64
    
    let unboxed: Unboxed
    
    init<Integer: UnsignedInteger>(_ unboxed: Integer) {
        self.unboxed = Unboxed(unboxed)
    }
    
    init?(string: String) {
        guard let unboxed = Unboxed(string) else {
            return nil
        }
        self.init(unboxed)
    }
    
    func unbox<Integer: BinaryInteger>() -> Integer? {
        return Integer(exactly: self.unboxed)
    }
}

extension UIntBox: Box {
    var isNull: Bool {
        return false
    }
    
    var isFragment: Bool {
        return true
    }
    
    var xmlString: String? {
        return self.unboxed.description
    }
}

extension UIntBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
