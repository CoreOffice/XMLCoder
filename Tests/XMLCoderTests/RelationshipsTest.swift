import XCTest
@testable import XMLCoder

private let xml = """
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship
        Id="rId1"
        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
        Target="xl/workbook.xml"/>
    <Relationship
        Id="rId2"
        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
        Target="docProps/app.xml"/>
    <Relationship
        Id="rId3"
        Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
        Target="docProps/core.xml"/>
</Relationships>
""".data(using: .utf8)!

private struct Relationships: Codable {
    let items: [Relationship]

    enum CodingKeys: String, CodingKey {
        case items = "relationship"
    }
}

private struct Relationship: Codable {
    enum SchemaType: String, Codable {
        case officeDocument = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
        case extendedProperties = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
        case coreProperties = "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
    }

    let id: String
    let type: SchemaType
    let target: String

    enum CodingKeys: CodingKey {
        case type
        case id
        case target
    }
}

private struct NodeCodingStrategyProvider {
    typealias Strategy = (CodingKey) -> XMLEncoder.NodeEncoding

    private func strategy(for _: Relationship.Type) -> Strategy {
        return { _ in .attribute }
    }

    func strategy(for type: Any.Type) -> Strategy {
        switch type {
        case let concreteType as Relationship.Type:
            return strategy(for: concreteType)
        case _:
            return { _ in .default }
        }
    }
}

final class RelationshipsTest: XCTestCase {
    func testDecoder() throws {
        let strategyProvider = NodeCodingStrategyProvider()

        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.nodeDecodingStrategy = .custom { type, _ in
            return strategyProvider.strategy(for: type)
        }

        do {
            try decoder.decode(Relationships.self, from: xml)
        } catch {
            fatalError("\(error)")
        }

        let rels = try decoder.decode(Relationships.self, from: xml)

        XCTAssertEqual(rels.items[0].id, "rId1")
    }

    static var allTests = [
        ("testDecoder", testDecoder),
    ]
}
