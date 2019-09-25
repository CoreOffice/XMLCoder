//
//  XMLStackParser.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

class XMLStackParser: NSObject {
    var root: XMLCoderElement?
    private var stack: [XMLCoderElement] = []
    private let trimValueWhitespaces: Bool

    init(trimValueWhitespaces: Bool = true) {
        self.trimValueWhitespaces = trimValueWhitespaces
        super.init()
    }

    static func parse(
        with data: Data,
        errorContextLength length: UInt,
        shouldProcessNamespaces: Bool,
        trimValueWhitespaces: Bool
    ) throws -> KeyedBox {
        let parser = XMLStackParser(trimValueWhitespaces: trimValueWhitespaces)

        let node = try parser.parse(
            with: data,
            errorContextLength: length,
            shouldProcessNamespaces: shouldProcessNamespaces
        )

        return node.transformToBoxTree()
    }

    func parse(
        with data: Data,
        errorContextLength: UInt,
        shouldProcessNamespaces: Bool
    ) throws -> XMLCoderElement {
        let xmlParser = XMLParser(data: data)
        xmlParser.shouldProcessNamespaces = shouldProcessNamespaces
        xmlParser.delegate = self

        guard !xmlParser.parse() || root == nil else {
            return root!
        }

        guard let error = xmlParser.parserError else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "The given data could not be parsed into XML."
            ))
        }

        // `lineNumber` isn't 0-indexed, so 0 is an invalid value for context
        guard errorContextLength > 0 && xmlParser.lineNumber > 0 else {
            throw error
        }

        let string = String(data: data, encoding: .utf8) ?? ""
        let lines = string.split(separator: "\n")
        var errorPosition = 0
        let offset = Int(errorContextLength / 2)
        for i in 0..<xmlParser.lineNumber - 1 {
            errorPosition += lines[i].count
        }
        errorPosition += xmlParser.columnNumber

        var lowerBoundIndex = 0
        if errorPosition - offset > 0 {
            lowerBoundIndex = errorPosition - offset
        }

        var upperBoundIndex = string.count
        if errorPosition + offset < string.count {
            upperBoundIndex = errorPosition + offset
        }

        #if compiler(>=5.0)
        let lowerBound = String.Index(utf16Offset: lowerBoundIndex, in: string)
        let upperBound = String.Index(utf16Offset: upperBoundIndex, in: string)
        #else
        let lowerBound = String.Index(encodedOffset: lowerBoundIndex)
        let upperBound = String.Index(encodedOffset: upperBoundIndex)
        #endif

        let context = string[lowerBound..<upperBound]

        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: [],
            debugDescription: """
            \(error.localizedDescription) \
            at line \(xmlParser.lineNumber), column \(xmlParser.columnNumber):
            `\(context)`
            """,
            underlyingError: error
        ))
    }

    func withCurrentElement(_ body: (inout XMLCoderElement) throws -> ()) rethrows {
        guard !stack.isEmpty else {
            return
        }
        try body(&stack[stack.count - 1])
    }

    /// Trim whitespaces for a given string if needed.
    func process(string: String) -> String {
        return trimValueWhitespaces
            ? string.trimmingCharacters(in: .whitespacesAndNewlines)
            : string
    }
}

extension XMLStackParser: XMLParserDelegate {
    func parserDidStartDocument(_: XMLParser) {
        root = nil
        stack = []
    }

    func parser(_: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?,
                attributes attributeDict: [String: String] = [:]) {
        #if os(Linux) && !compiler(>=5.1)
        // For some reason, element names on linux are coming out with the namespace after the name
        // https://bugs.swift.org/browse/SR-11191
        let elementName = elementName.components(separatedBy: ":").reversed().joined(separator: ":")
        #endif
        let attributes = attributeDict.map { key, value in
            Attribute(key: key, value: value)
        }
        let element = XMLCoderElement(key: elementName, attributes: attributes)
        stack.append(element)
    }

    func parser(_: XMLParser,
                didEndElement _: String,
                namespaceURI _: String?,
                qualifiedName _: String?) {
        guard let element = stack.popLast() else {
            return
        }

        withCurrentElement { currentElement in
            currentElement.append(element: element, forKey: element.key)
        }

        if stack.isEmpty {
            root = element
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        withCurrentElement { currentElement in
            currentElement.append(value: process(string: string))
        }
    }

    func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }

        withCurrentElement { currentElement in
            currentElement.append(value: process(string: string))
        }
    }
}
