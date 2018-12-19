//
//  DecimalBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct DecimalBox: Equatable {
    typealias Unboxed = Decimal
    
    let unboxed: Unboxed
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    init?(string: String) {
        guard let unboxed = Unboxed(string: string) else {
            return nil
        }
        self.init(unboxed)
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension DecimalBox: Box {
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

extension DecimalBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
