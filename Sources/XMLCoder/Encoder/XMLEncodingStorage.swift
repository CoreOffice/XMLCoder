
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
    private var containers: [NSObject] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    init() {}

    // MARK: - Modifying the Stack

    var count: Int {
        return containers.count
    }

    var lastContainer: NSObject? {
        return containers.last
    }

    mutating func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        containers.append(dictionary)
        return dictionary
    }

    mutating func pushUnkeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        containers.append(array)
        return array
    }

    mutating func push(container: NSObject) {
        containers.append(container)
    }

    mutating func popContainer() -> NSObject {
        precondition(!containers.isEmpty, "Empty container stack.")
        return containers.popLast()!
    }
}
