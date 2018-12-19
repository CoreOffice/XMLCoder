//
//  FloatBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct FloatBox: Equatable {
    typealias Unboxed = Float64
    
    let unboxed: Unboxed
    
    init<Float: BinaryFloatingPoint>(_ unboxed: Float) {
        self.unboxed = Unboxed(unboxed)
    }
    
    init?(string: String) {
        guard let unboxed = Unboxed(string) else {
            return nil
        }
        self.init(unboxed)
    }
    
    func unbox<Float: BinaryFloatingPoint>() -> Float? {
        return Float(exactly: self.unboxed)
    }
}

extension FloatBox: Box {
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

extension FloatBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
