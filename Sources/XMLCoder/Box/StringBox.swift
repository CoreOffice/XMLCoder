//
//  StringBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

struct StringBox: Equatable {
    typealias Unboxed = String
    
    let unboxed: Unboxed
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    init(xmlString: Unboxed) {
        self.init(xmlString)
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension StringBox: Box {
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

extension StringBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
