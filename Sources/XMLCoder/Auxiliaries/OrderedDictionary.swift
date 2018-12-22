//
//  OrderedDictionary.swift
//  XMLCoder
//
//  Created by James Bean on 12/22/18.
//

/// Ordered collection of key-value pairs.
struct OrderedDictionary <Key: Hashable, Value> {

    // MARK: - Instance Properties

    /// Keys in order.
    var keys: [Key] = []

    /// - Returns: The values in order.
    public var values: [Value] {
        return keys.map { self[$0]! }
    }

    /// Unordered dictionary of key-value pairs.
    private var unordered: [Key: Value] = [:]

    // MARK: - Initializers

    /// Creates an empty `OrderedDictionary`.
    init(keys: [Key] = [], unordered: [Key: Value] = [:]) {
        self.keys = keys
        self.unordered = unordered
    }

    /// Creates an `OrderedDictionary` from an unordered `Dictionary`.
    init(_ unordered: [Key: Value]) {
        self.init(keys: Array(unordered.keys), unordered: unordered)
    }

    /// Creates an `OrderedDictionary` with given array of `uniqueKeysWithValues`.
    init(uniqueKeysWithValues: [(Key,Value)]) {
        let keys = uniqueKeysWithValues.map { $0.0 }
        let unordered = Dictionary(uniqueKeysWithValues: uniqueKeysWithValues)
        self.init(keys: keys, unordered: unordered)
    }

    /// Creates an `OrderedDictionary` with the given `keysAndValues` along with the `uniquingKeys
    init <S> (
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows where S : Sequence, S.Element == (Key,Value)
    {
        let unordered = try Dictionary(keysAndValues, uniquingKeysWith: combine)
        let keys = keysAndValues.map { $0.0 }.removingDuplicates()
        self.init(keys: keys, unordered: unordered)
    }

    /// Creates an empty `OrderedDictionary` type with preallocated space for at least the specified
    /// number of elements.
    init(minimumCapacity: Int) {
        self.keys = []
        self.keys.reserveCapacity(minimumCapacity)
        self.unordered = .init(minimumCapacity: minimumCapacity)
    }

    // MARK: - Subscripts

    /// - Returns: Value for the given `key`, if available. Otherwise, `nil`.
    public subscript(key: Key) -> Value? {
        get {
            return unordered[key]
        }
        set {
            guard let newValue = newValue else {
                unordered.removeValue(forKey: key)
                keys.removeAll { $0 == key }
                return
            }
            let oldValue = unordered.updateValue(newValue, forKey: key)
            if oldValue == nil { keys.append(key) }
        }
    }

    // MARK: - Instance Methods

    /// Appends `value` for given `key`.
    mutating func append(_ value: Value, key: Key) {
        keys.append(key)
        unordered[key] = value
    }

    /// Inserts `value` for given `key` at `index`.
    mutating func insert(_ value: Value, key: Key, index: Int) {
        keys.insert(key, at: index)
        unordered[key] = value
    }

    /// - Returns: An `OrderedDictionary` with values mapped by the given `transform`.
    func mapValues <U> (_ transform: (Value) throws -> U) rethrows -> OrderedDictionary<Key,U> {
        return OrderedDictionary<Key,U>(keys: keys, unordered: try unordered.mapValues(transform))
    }

    /// - Returns: An array of key-value pairs sorted by the given comparison closure.
    func sorted(
        by areInIncreasingOrder: ((key: Key, value: Value), (key: Key, value: Value)) throws -> Bool
    ) rethrows -> OrderedDictionary
    {
        return OrderedDictionary(uniqueKeysWithValues: try sorted(by: areInIncreasingOrder))
    }
}

extension OrderedDictionary: Collection {

    // MARK: - Collection

    /// - Index after given index `i`.
    public func index(after i: Int) -> Int {
        precondition(i < endIndex, "Cannot increment beyond endIndex")
        return i + 1
    }

    /// Start index.
    public var startIndex: Int {
        return keys.startIndex
    }

    /// End index.
    public var endIndex: Int {
        return keys.endIndex
    }

    /// - Returns: Element at the given `index`.
    public subscript (index: Int) -> (key: Key, value: Value) {
        let key = keys[index]
        let value = unordered[key]!
        return (key,value)
    }
}

extension OrderedDictionary: Equatable where Value: Equatable { }
extension OrderedDictionary: Hashable where Value: Hashable { }

extension OrderedDictionary: ExpressibleByDictionaryLiteral {

    // MARK: - ExpressibleByDictionaryLiteral

    /// Create an `OrderedDictionary` with a `DictionaryLiteral`.
    public init(dictionaryLiteral elements: (Key,Value)...) {
        self.init(minimumCapacity: elements.count)
        elements.forEach { (k,v) in append(v, key: k) }
    }
}

extension OrderedDictionary: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// - Returns: A string that represents the contents of the `OrderedDictionary`.
    public var description: String {
        if self.count == 0 { return "[:]" }
        var result = "["
        var first = true
        for (key,value) in self {
            if first {
                first = false
            } else {
                result += ", "
            }
            debugPrint(key, terminator: "", to: &result)
            result += ": "
            debugPrint(value, terminator: "", to: &result)
        }
        result += "]"
        return result
    }
}

extension Array where Element: Equatable {
    /// - Returns: An array of values with no duplicate values.
    func removingDuplicates() -> Array {
        var result: Array = []
        for element in self where !result.contains(element) {
            result.append(element)
        }
        return result
    }
}
