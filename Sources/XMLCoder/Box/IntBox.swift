//
//  IntBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct IntBox: Equatable {
    typealias Unboxed = Int
    
    let unboxed: Unboxed
    
    init<Integer: SignedInteger>(_ unboxed: Integer) {
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

extension IntBox: Box {
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

extension IntBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
