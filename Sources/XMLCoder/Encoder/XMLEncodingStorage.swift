
//
//  XMLEncodingStorage.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/22/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - Encoding Storage and Containers

internal struct _XMLEncodingStorage {
    // MARK: Properties

    /// The container stack.
    private var containers: [Box] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    init() {}

    // MARK: - Modifying the Stack

    var count: Int {
        return containers.count
    }

    var lastContainer: Box? {
        return containers.last
    }

    mutating func pushKeyedContainer() -> DictionaryBox {
        let dictionary = DictionaryBox()
        containers.append(Box.dictionary(dictionary))
        return dictionary
    }

    mutating func pushUnkeyedContainer() -> ArrayBox {
        let array = ArrayBox()
        containers.append(Box.array(array))
        return array
    }

    mutating func push(container: Box) {
        containers.append(container)
    }

    mutating func popContainer() -> Box {
        precondition(!containers.isEmpty, "Empty container stack.")
        return containers.popLast()!
    }
}
