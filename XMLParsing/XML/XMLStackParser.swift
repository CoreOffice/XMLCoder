//
//  XMLStackParser.swift
//  CustomEncoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

//===----------------------------------------------------------------------===//
// Data Representation
//===----------------------------------------------------------------------===//

import Foundation

internal class _XMLElement {
    var key: String
    var value: String? = nil
    var attributes: [String: String] = [:]
    var children: [String: [_XMLElement]] = [:]
    
    fileprivate init(key: String, value: String? = nil, attributes: [String: String] = [:], children: [String: [_XMLElement]] = [:]) {
        self.key = key
        self.value = value
        self.attributes = attributes
        self.children = children
    }
    
    convenience init(key: String, value: Optional<CustomStringConvertible>, attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: value?.description, attributes: attributes.mapValues({ $0.description }), children: [:])
    }
    
    convenience init(key: String, children: [String: [_XMLElement]], attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: nil, attributes: attributes.mapValues({ $0.description }), children: children)
    }
    
    func flatten() -> [String: Any] {
        var node: [String: Any] = attributes
        
        for childElement in children {
            for child in childElement.value {
                if let content = child.value {
                    node[childElement.key] = content
                } else if !child.attributes.isEmpty || !child.attributes.isEmpty {
                    let newValue = child.flatten()
                    
                    if let existingValue = node[childElement.key] {
                        if var array = existingValue as? Array<Any> {
                            array.append(newValue)
                            node[childElement.key] = array
                        } else {
                            node[childElement.key] = [existingValue, newValue]
                        }
                    } else {
                        node[childElement.key] = newValue
                    }
                }
            }
        }
        
        return node
    }
    
    func toXMLString(indented level: Int = 0) -> String {
        func escapeString(_ string: String) -> String {
            var string = string
            
            for (character, escapedCharacter) in [("&", "&amp"), ("<", "&lt;"), (">", "&gt;"), /*( "'", "&apos;"),*/ ("\"", "&quot;")] {
                string = string.replacingOccurrences(of: character, with: escapedCharacter, options: .literal)
            }
            
            return string
        }
        
        var string = String(repeating: " ", count: level * 4)
        string += "<\(key)"
        
        for (key, value) in attributes {
            string += " \(key)=\"\(escapeString(value))\""
        }
        
        if let value = value {
            string += ">"
            string += /*(isCDATA == true ? "<![CDATA[\(value)]]>" :*/ "\(escapeString(value))" /*)*/
            string += "</\(key)>"
        } else if !children.isEmpty {
            string += ">\n"
            
            for childElement in children {
                for child in childElement.value {
                    string += child.toXMLString(indented: level + 1)
                    string += "\n"
                }
            }
            
            string += String(repeating: " ", count: level * 4)
            string += "</\(key)>"
        } else {
            string += " />"
        }
        
        return string
    }
}

internal class _XMLStackParser: NSObject, XMLParserDelegate {
    var root: _XMLElement?
    var stack = [_XMLElement]()
    var currentNode: _XMLElement?
    
    var currentElementName: String?
    var currentElementData = ""
    
    static func parse(with data: Data) throws -> [String: Any] {
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
    
    func parse(with data: Data) throws -> _XMLElement?  {
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
    
    func parserDidStartDocument(_ parser: XMLParser) {
        root = nil
        stack = [_XMLElement]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
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
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let poppedNode = stack.popLast(){
            if let content = poppedNode.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if content.isEmpty {
                    poppedNode.value = nil
                } else {
                    poppedNode.value = content
                }
            }
            
            if (stack.isEmpty) {
                root = poppedNode
                currentNode = nil
            } else {
                currentNode = stack.last
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentNode?.value = (currentNode?.value ?? "") + string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentNode?.value = (currentNode?.value ?? "") + string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}

