import XCTest
@testable import XMLCoder

fileprivate struct SingleContainer: Encodable {
    let element: Element

    enum CodingKeys: String, CodingKey {
        case element
    }
}

fileprivate struct KeyedContainer: Encodable {
    let elements: [String: Element]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

fileprivate struct UnkeyedContainer: Encodable {
    let elements: [Element]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

fileprivate struct Element: Encodable {
    let key: String = "value"
    let intKey: Int = 42
    let int8Key: Int8 = 42
    let doubleKey: Double = 42.42

    enum CodingKeys: CodingKey {
        case key
        case intKey
        case int8Key
        case doubleKey
    }
}

private struct NodeCodingStrategyProvider {
    typealias Strategy = (CodingKey) -> XMLEncoder.NodeEncoding

    private func strategy(for _: Element.Type) -> Strategy {
        return { _ in .attribute }
    }

    func strategy(for type: Any.Type) -> Strategy {
        switch type {
        case let concreteType as Element.Type:
            return strategy(for: concreteType)
        case _:
            return { _ in .default }
        }
    }
}

final class NodeEncodingStrategyTests: XCTestCase {
    func testSingleContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let strategyProvider = NodeCodingStrategyProvider()

        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { type, _ in
            return strategyProvider.strategy(for: type)
        }

        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testKeyedContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let strategyProvider = NodeCodingStrategyProvider()

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <first>
                            <doubleKey>42.42</doubleKey>
                            <int8Key>42</int8Key>
                            <intKey>42</intKey>
                            <key>value</key>
                        </first>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { type, _ in
            return strategyProvider.strategy(for: type)
        }

        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <first doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testUnkeyedContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let strategyProvider = NodeCodingStrategyProvider()

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { type, _ in
            return strategyProvider.strategy(for: type)
        }

        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    static var allTests = [
        ("testSingleContainer", testSingleContainer),
        ("testKeyedContainer", testKeyedContainer),
        ("testUnkeyedContainer", testUnkeyedContainer),
    ]
}
