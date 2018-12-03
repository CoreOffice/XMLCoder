
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
    /// Elements may be any one of the XML types (NSNull, NSNumber, NSString, NSArray, NSDictionary).
    internal private(set) var containers: [NSObject] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    internal init() {}

    // MARK: - Modifying the Stack

    internal var count: Int {
        return containers.count
    }

    internal mutating func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        containers.append(dictionary)
        return dictionary
    }

    internal mutating func pushUnkeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        containers.append(array)
        return array
    }

    internal mutating func push(container: NSObject) {
        containers.append(container)
    }

    internal mutating func popContainer() -> NSObject {
        precondition(!containers.isEmpty, "Empty container stack.")
        return containers.popLast()!
    }
}
