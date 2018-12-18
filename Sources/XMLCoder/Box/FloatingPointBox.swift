//
//  FloatingPointBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal struct FloatingPointBox: Equatable {
    typealias Unboxed = Float64
    
    let unboxed: Unboxed
    
    init<Float: BinaryFloatingPoint>(_ unboxed: Float) {
        self.unboxed = Unboxed(unboxed)
    }
    
    func unbox<Float: BinaryFloatingPoint>() -> Float? {
        return Float(exactly: self.unboxed)
    }
}

extension FloatingPointBox: Box {
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

extension FloatingPointBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
