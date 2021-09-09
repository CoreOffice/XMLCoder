protocol XMLPositionIndexedProtocol { }

public struct XMLPositionIndexed<T: Decodable>: Decodable, XMLPositionIndexedProtocol {
    public let index: Int
    public let value: T
}
