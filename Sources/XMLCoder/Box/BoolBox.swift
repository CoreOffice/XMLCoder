//
//  BoolBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal struct BoolBox: Equatable {
    typealias Unboxed = Bool
    
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

extension BoolBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
