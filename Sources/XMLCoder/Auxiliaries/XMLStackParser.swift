//
//  XMLStackParser.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

internal class _XMLStackParser: NSObject, XMLParserDelegate {
    var root: _XMLElement?
    var stack = [_XMLElement]()
    var currentNode: _XMLElement?

    var currentElementName: String?
    var currentElementData = ""

    static func parse(with data: Data) throws -> [String: Box] {
        let parser = _XMLStackParser()

        do {
            if let node = try parser.parse(with: data) {
                return node.flatten()
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data could not be parsed into XML."))
            }
        } catch {
            throw error
        }
    }

    func parse(with data: Data) throws -> _XMLElement? {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self

        if xmlParser.parse() {
            return root
        } else if let error = xmlParser.parserError {
            throw error
        } else {
            return nil
        }
    }

    func parserDidStartDocument(_: XMLParser) {
        root = nil
        stack = [_XMLElement]()
    }

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        let node = _XMLElement(key: elementName)
        node.attributes = attributeDict
        stack.append(node)

        if let currentNode = currentNode {
            if currentNode.children[elementName] != nil {
                currentNode.children[elementName]?.append(node)
            } else {
                currentNode.children[elementName] = [node]
            }
        }
        currentNode = node
    }

    func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        if let poppedNode = stack.popLast() {
            if let content = poppedNode.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if content.isEmpty {
                    poppedNode.value = nil
                } else {
                    poppedNode.value = content
                }
            }

            if stack.isEmpty {
                root = poppedNode
                currentNode = nil
            } else {
                currentNode = stack.last
            }
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        currentNode?.value = (currentNode?.value ?? "") + string
    }

    func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentNode?.value = (currentNode?.value ?? "") + string
        }
    }

    func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
