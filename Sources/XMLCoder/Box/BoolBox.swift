//
//  BoolBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct BoolBox: Equatable {
    typealias Unboxed = Bool
    
    let unboxed: Unboxed
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    init?(xmlString: String) {
        switch xmlString {
        case "false", "0": self.init(false)
        case "true", "1": self.init(true)
        case _: return nil
        }
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension BoolBox: Box {
    var isNull: Bool {
        return false
    }
    
    /// # Lexical representation
    /// Boolean has a lexical representation consisting of the following
    /// legal literals {`true`, `false`, `1`, `0`}.
    ///
    /// # Canonical representation
    /// The canonical representation for boolean is the set of literals {`true`, `false`}.
    ///
    /// ---
    ///
    /// [Schema definition](https://www.w3.org/TR/xmlschema-2/#boolean)
    func xmlString() -> String? {
        return (self.unboxed) ? "true" : "false"
    }
}

extension BoolBox: SimpleBox {
    
}

extension BoolBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
