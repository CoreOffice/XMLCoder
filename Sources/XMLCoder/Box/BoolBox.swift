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
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension BoolBox: Box {
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

extension BoolBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
