//
//  Box.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/17/18.
//

import Foundation

protocol Box {
    var isNull: Bool { get }
    func xmlString() -> String?
}

/// A box that only describes a single atomic value.
protocol SimpleBox: Box {
    
}
