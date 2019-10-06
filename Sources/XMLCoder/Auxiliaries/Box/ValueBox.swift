//
//  File.swift
//  XMLCoder
//
//  Created by Max Desiatov on 05/10/2019.
//

protocol ValueBox: SimpleBox {
    associatedtype Unboxed

    init(_ value: Unboxed)
}
