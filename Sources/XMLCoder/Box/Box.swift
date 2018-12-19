//
//  Box.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

protocol Box {
    var isNull: Bool { get }
    var isFragment: Bool { get }
    
    func xmlString() -> String?
}
