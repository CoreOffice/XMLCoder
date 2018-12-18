//
//  DecimalBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal struct DecimalBox: Equatable {
    typealias Unboxed = Decimal
    
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

extension DecimalBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
