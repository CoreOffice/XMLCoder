//
//  XMLDecodingStorage.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - Decoding Storage

struct _XMLDecodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements may be any one of the XML types (StringBox, KeyedBox).
    private var containers: [Box] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    init() {}

    // MARK: - Modifying the Stack

    var count: Int {
        return containers.count
    }

    func topContainer() -> Box? {
        return containers.last
    }

    mutating func push(container: Box) {
        containers.append(container)
    }

    @discardableResult
    mutating func popContainer() -> Box? {
        guard !containers.isEmpty else {
            return nil
        }
        return containers.removeLast()
    }
}
