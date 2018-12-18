//
//  SignedIntegerBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal struct SignedIntegerBox: Equatable {
    typealias Unboxed = Int
    
    let unboxed: Unboxed
    
    init<Integer: SignedInteger>(_ unboxed: Integer) {
        self.unboxed = Unboxed(unboxed)
    }
    
    func unbox<Integer: BinaryInteger>() -> Integer? {
        return Integer(exactly: self.unboxed)
    }
}

extension SignedIntegerBox: Box {
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

extension SignedIntegerBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
