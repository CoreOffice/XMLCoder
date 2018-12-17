//
//  NullBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

internal class NullBox {
    static let shared: NullBox = .init()
    
    init() {
        
    }
}

extension NullBox: CustomStringConvertible {
    var description: String {
        return "<null>"
    }
}
