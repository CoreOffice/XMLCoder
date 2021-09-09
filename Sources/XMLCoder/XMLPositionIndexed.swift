public protocol XMLPositionIndexedElementProtocol { }
public protocol XMLPositionIndexedSequenceProtocol { }

public struct XMLPositionIndexed<T: Decodable>: Decodable, XMLPositionIndexedElementProtocol {
    public let index: Int
    public let value: T
}

extension Array: XMLPositionIndexedSequenceProtocol where Element: XMLPositionIndexedElementProtocol { }
