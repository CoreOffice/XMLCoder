import XCTest
@testable import XMLCoder

class BenchmarkTests: XCTestCase {
    struct Container<T: Codable>: Codable {
        let unkeyed: [T]
        let keyed: [String: T]
    }

    func container<T: Codable>(with value: T) -> Container<T> {
        // unkeyed.count + keyed.count = self.count:
        let count = self.count / 2

        let unkeyed = [T](repeating: value, count: count)
        let keyed = Dictionary(uniqueKeysWithValues: unkeyed.enumerated().map { index, value in
            ("key_\(index)", value)
        })

        return Container(unkeyed: unkeyed, keyed: keyed)
    }

    func encodedContainer<T: Codable>(of _: T.Type, with value: T) throws -> Data {
        let container = self.container(with: value)

        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        return try encoder.encode(container, withRootKey: "container")
    }

    func testEncoding<T: Codable>(with value: T, _ closure: (() -> ()) -> ()) throws {
        try testEncoding(of: T.self, with: value, closure)
    }

    func testEncoding<T: Codable>(of _: T.Type, with value: T, _ closure: (() -> ()) -> ()) throws {
        let container: Container<T> = self.container(with: value)

        let encoder = XMLEncoder()

        var caughtError: Error?

        closure {
            do {
                _ = try encoder.encode(container, withRootKey: "container")
            } catch {
                caughtError = error
            }
        }

        if let error = caughtError {
            throw error
        }
    }

    func testDecoding<T: Codable>(with value: T, _ closure: (() -> ()) -> ()) throws {
        try testDecoding(of: T.self, with: value, closure)
    }

    func testDecoding<T: Codable>(of _: T.Type, with value: T, _ closure: (() -> ()) -> ()) throws {
        let data: Data = try encodedContainer(of: T.self, with: value)

        let decoder = XMLDecoder()

        var caughtError: Error?

        closure {
            do {
                _ = try decoder.decode(Container<T>.self, from: data)
            } catch {
                caughtError = error
            }
        }

        if let error = caughtError {
            throw error
        }
    }

    let count: Int = 1000

    let null: Bool? = nil
    let bool: Bool = true
    let int: Int = -42
    let uint: UInt = 42
    let float: Float = 42.0
    let decimal: Decimal = 42.0
    let date: Date = Date()
    let data: Data = Data(base64Encoded: "bG9yZW0gaXBzdW0=")!
    let url: URL = URL(string: "http://example.com")!
    let array: [Int] = [1, 2, 3, 4, 5]
    let dictionary: [String: Int] = ["key_1": 1, "key_2": 2, "key_3": 3, "key_4": 4, "key_5": 5]

    func testEncodeNulls() throws {
        try testEncoding(with: null) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeNulls() throws {
        try testDecoding(with: null) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeBools() throws {
        try testEncoding(with: bool) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeBools() throws {
        try testDecoding(with: bool) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeInts() throws {
        try testEncoding(with: int) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeInts() throws {
        try testDecoding(with: int) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeUInts() throws {
        try testEncoding(with: uint) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeUInts() throws {
        try testDecoding(with: uint) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeFloats() throws {
        try testEncoding(with: float) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeFloats() throws {
        try testDecoding(with: float) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeDecimals() throws {
        try testEncoding(with: decimal) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeDecimals() throws {
        try testDecoding(with: decimal) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeDates() throws {
        try testEncoding(with: date) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeDates() throws {
        try testDecoding(with: date) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeDatas() throws {
        try testEncoding(with: data) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeDatas() throws {
        try testDecoding(with: data) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeURLs() throws {
        try testEncoding(with: url) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeURLs() throws {
        try testDecoding(with: url) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeArrays() throws {
        try testEncoding(with: array) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeArrays() throws {
        try testDecoding(with: array) { closure in
            self.measure { closure() }
        }
    }

    func testEncodeDictionaries() throws {
        try testEncoding(with: dictionary) { closure in
            self.measure { closure() }
        }
    }

    func testDecodeDictionaries() throws {
        try testDecoding(with: dictionary) { closure in
            self.measure { closure() }
        }
    }

    static var allTests = [
        ("testEncodeNulls", testEncodeNulls),
        ("testDecodeNulls", testDecodeNulls),
        ("testEncodeBools", testEncodeBools),
        ("testDecodeBools", testDecodeBools),
        ("testEncodeInts", testEncodeInts),
        ("testDecodeInts", testDecodeInts),
        ("testEncodeUInts", testEncodeUInts),
        ("testDecodeUInts", testDecodeUInts),
        ("testEncodeFloats", testEncodeFloats),
        ("testDecodeFloats", testDecodeFloats),
        ("testEncodeDecimals", testEncodeDecimals),
        ("testDecodeDecimals", testDecodeDecimals),
        ("testEncodeArrays", testEncodeArrays),
        ("testDecodeArrays", testDecodeArrays),
        ("testEncodeDictionaries", testEncodeDictionaries),
        ("testDecodeDictionaries", testDecodeDictionaries),
    ]
}
