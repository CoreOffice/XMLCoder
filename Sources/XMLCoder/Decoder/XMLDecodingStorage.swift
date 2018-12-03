//
//  XMLDecodingStorage.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - Decoding Storage

internal struct _XMLDecodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements may be any one of the XML types (String, [String : Any]).
    internal private(set) var containers: [Any] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    internal init() {}

    // MARK: - Modifying the Stack

    internal var count: Int {
        return containers.count
    }

    internal var topContainer: Any {
        precondition(!containers.isEmpty, "Empty container stack.")
        return containers.last!
    }

    internal mutating func push(container: Any) {
        containers.append(container)
    }

    internal mutating func popContainer() {
        precondition(!containers.isEmpty, "Empty container stack.")
        containers.removeLast()
    }
}
