//
//  NullBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal struct NullBox {
    init() {}
}

extension NullBox: Box {
    var isNull: Bool {
        return true
    }
    
    var isFragment: Bool {
        return true
    }
    
    var xmlString: String? {
        return nil
    }
}

extension NullBox: Equatable {
    static func == (lhs: NullBox, rhs: NullBox) -> Bool {
        return true
    }
}

extension NullBox: CustomStringConvertible {
    var description: String {
        return "null"
    }
}
