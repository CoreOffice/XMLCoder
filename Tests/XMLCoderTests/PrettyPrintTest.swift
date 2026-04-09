// Copyright (c) 2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import XCTest
import XMLCoder

private struct TopContainer: Encodable {
    let nested: NestedContainer
}

private struct NestedContainer: Encodable {
    let values: [String]
}

/// Element with an attribute and intrinsic text value (empty-string CodingKey).
private struct Measurement: Codable, Equatable {
    @Attribute var ref: String?
    var value: Double

    enum CodingKeys: String, CodingKey {
        case ref
        case value = ""
    }

    init(value: Double, ref: String? = nil) {
        self._ref = Attribute(ref)
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ref = try container.decodeIfPresent(Attribute<String?>.self, forKey: .ref) ?? Attribute(nil)
        value = try container.decode(Double.self, forKey: .value)
    }
}

private struct Sample: Codable, Equatable {
    var depth: Double
    var readings: [Measurement]

    enum CodingKeys: String, CodingKey {
        case depth
        case readings = "measurement"
    }

    init(depth: Double, readings: [Measurement]) {
        self.depth = depth
        self.readings = readings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        depth = try container.decode(Double.self, forKey: .depth)
        readings = try container.decodeIfPresent([Measurement].self, forKey: .readings) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(depth, forKey: .depth)
        for reading in readings {
            let enc = container.superEncoder(forKey: .readings)
            try reading.encode(to: enc)
        }
    }
}

final class PrettyPrintTest: XCTestCase {
    private let testContainer = TopContainer(nested: NestedContainer(values: ["foor", "bar"]))

    func testDefaultIndentation() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
                <nested>
                    <values>foor</values>
                    <values>bar</values>
                </nested>
            </TopContainer>
            """
        )
    }

    func testSpaces() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .spaces(3)

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
               <nested>
                  <values>foor</values>
                  <values>bar</values>
               </nested>
            </TopContainer>
            """
        )
    }

    func testIntrinsicValueWithoutAttribute() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .spaces(4)

        let sample = Sample(depth: 6.0, readings: [
            Measurement(value: 118000.0),
        ])
        let encoded = try encoder.encode(sample, withRootKey: "sample")

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <sample>
                <depth>6.0</depth>
                <measurement>118000.0</measurement>
            </sample>
            """
        )

        let decoded = try XMLDecoder().decode(Sample.self, from: encoded)
        XCTAssertEqual(decoded, sample)
    }

    func testIntrinsicValueWithAttribute() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .spaces(4)

        let sample = Sample(depth: 30.0, readings: [
            Measurement(value: 120000.0, ref: "sensor-1"),
            Measurement(value: 122000.0, ref: "sensor-2"),
        ])
        let encoded = try encoder.encode(sample, withRootKey: "sample")

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <sample>
                <depth>30.0</depth>
                <measurement ref="sensor-1">120000.0</measurement>
                <measurement ref="sensor-2">122000.0</measurement>
            </sample>
            """
        )

        let decoded = try XMLDecoder().decode(Sample.self, from: encoded)
        XCTAssertEqual(decoded, sample)
    }

    func testTabs() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .tabs(2)

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
            \t\t<nested>
            \t\t\t\t<values>foor</values>
            \t\t\t\t<values>bar</values>
            \t\t</nested>
            </TopContainer>
            """
        )
    }
}
