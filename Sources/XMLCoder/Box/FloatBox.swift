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
    
    init?(xmlString: String) {
        guard let unboxed = Unboxed(xmlString) else {
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
    
    /// # Lexical representation
    /// float values have a lexical representation consisting of a mantissa followed, optionally,
    /// by the character `"E"` or `"e"`, followed by an exponent. The exponent **must** be an integer.
    /// The mantissa **must** be a decimal number. The representations for exponent and mantissa **must**
    /// follow the lexical rules for integer and decimal. If the `"E"` or `"e"` and the following
    /// exponent are omitted, an exponent value of `0` is assumed.
    ///
    /// The special values positive and negative infinity and not-a-number have lexical
    /// representations `INF`, `-INF` and `NaN`, respectively. Lexical representations for zero
    /// may take a positive or negative sign.
    ///
    /// For example, `-1E4`, `1267.43233E12`, `12.78e-2`, `12` , `-0`, `0` and `INF` are all
    /// legal literals for float.
    ///
    /// # Canonical representation
    /// The canonical representation for float is defined by prohibiting certain options from the
    /// Lexical representation. Specifically, the exponent must be indicated by `"E"`.
    /// Leading zeroes and the preceding optional `"+"` sign are prohibited in the exponent.
    /// If the exponent is zero, it must be indicated by `"E0"`. For the mantissa, the preceding
    /// optional `"+"` sign is prohibited and the decimal point is required. Leading and trailing
    /// zeroes are prohibited subject to the following: number representations must be normalized
    /// such that there is a single digit which is non-zero to the left of the decimal point and
    /// at least a single digit to the right of the decimal point unless the value being represented
    /// is zero. The canonical representation for zero is `0.0E0`.
    ///
    /// ---
    ///
    /// [Schema definition](https://www.w3.org/TR/xmlschema-2/#float)
    func xmlString() -> String? {
        guard !self.unboxed.isNaN else {
            return "NaN"
        }
        
        guard !self.unboxed.isInfinite else {
            return (self.unboxed > 0.0) ? "INF" : "-INF"
        }
        
        return self.unboxed.description
    }
}

extension FloatBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
