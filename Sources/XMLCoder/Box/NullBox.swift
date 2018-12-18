//
//  NullBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal class NullBox {
    var xmlString: String {
        return ""
    }
    
    init() {
        
    }
}

extension NullBox: Equatable {
    static func == (lhs: NullBox, rhs: NullBox) -> Bool {
        return true
    }
}

extension NullBox: CustomStringConvertible {
    var description: String {
        return "<null>"
    }
}
