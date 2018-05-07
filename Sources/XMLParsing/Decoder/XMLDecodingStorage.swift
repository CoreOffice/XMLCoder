//
//  XMLDecodingStorage.swift
//  XMLParsing
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
    private(set) internal var containers: [Any] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    internal init() {}

    // MARK: - Modifying the Stack

    internal var count: Int {
        return self.containers.count
    }

    internal var topContainer: Any {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.last!
    }

    internal mutating func push(container: Any) {
        self.containers.append(container)
    }

    internal mutating func popContainer() {
        precondition(self.containers.count > 0, "Empty container stack.")
        self.containers.removeLast()
    }
}

