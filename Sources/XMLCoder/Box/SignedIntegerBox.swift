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
    
    var xmlString: String {
        return self.unboxed.description
    }
    
    init<Integer: SignedInteger>(_ unboxed: Integer) {
        self.unboxed = Unboxed(unboxed)
    }
    
    func unbox<Integer: BinaryInteger>() -> Integer? {
        return Integer(exactly: self.unboxed)
    }
}

extension SignedIntegerBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
