//
//  XMLStackParser.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

internal class _XMLStackParser: NSObject {
    var root: _XMLElement? = nil
    var stack: [_XMLElement] = []
    var currentNode: _XMLElement? = nil

    var currentElementName: String? = nil
    var currentElementData = ""

    static func parse(with data: Data) throws -> [String: Box] {
        let parser = _XMLStackParser()

        guard let node = try parser.parse(with: data) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "The given data could not be parsed into XML."
            ))
        }
        
        return node.flatten()
    }

    func parse(with data: Data) throws -> _XMLElement? {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        
        guard xmlParser.parse() else {
            if let error = xmlParser.parserError {
                throw error
            }
            return nil
        }
        
        return root
    }
}

extension _XMLStackParser: XMLParserDelegate {
    func parserDidStartDocument(_: XMLParser) {
        root = nil
        stack = []
    }

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        let node = _XMLElement(key: elementName, attributes: attributeDict)
        
        stack.append(node)
        
        currentNode?.children[elementName, default: []].append(node)
        
        currentNode = node
    }

    func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        guard let poppedNode = stack.popLast() else {
            return
        }
        
        if let value = poppedNode.value?.trimmingCharacters(in: .whitespacesAndNewlines) {
            poppedNode.value = value.isEmpty ? nil : value
        }

        if stack.isEmpty {
            root = poppedNode
        }
        
        currentNode = stack.last
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        guard let currentNode = currentNode else {
            return
        }
        
        var value = currentNode.value ?? ""
        value.append(string)
        currentNode.value = value
    }

    func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }
        guard let currentNode = currentNode else {
            return
        }
        
        var value = currentNode.value ?? ""
        value.append(string)
        currentNode.value = value
    }

    func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
