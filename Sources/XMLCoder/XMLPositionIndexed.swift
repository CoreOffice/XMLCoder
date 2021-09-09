public struct XMLPositionIndexed<T: Decodable>: Decodable, XMLPositionIndexedElementProtocol {
    public let index: Int
    public let value: T
}

// For type erasure

protocol XMLPositionIndexedElementProtocol { }
protocol XMLPositionIndexedSequenceProtocol { }

extension Array: XMLPositionIndexedSequenceProtocol where Element: XMLPositionIndexedElementProtocol { }
