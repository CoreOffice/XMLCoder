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

internal class _XMLNode {
    var name = ""
    var content: String?
    var properties = [String:[_XMLNode]]()
    var attributes = [String:String]()
    
    func flatten() -> [String: Any] {
        var node: [String: Any] = attributes
        
        for (key, property) in properties {
            for value in property {
                if let content = value.content {
                    node[key] = content
                } else if !value.attributes.isEmpty || !value.properties.isEmpty {
                    let newValue = value.flatten()
                    
                    if let existingValue = node[key] {
                        if var array = existingValue as? Array<Any> {
                            array.append(newValue)
                            node[key] = array
                        } else {
                            node[key] = [existingValue, newValue]
                        }
                    } else {
                        node[key] = newValue
                    }
                }
            }
        }
        
        return node
    }
}

internal class _XMLStackParser: NSObject, XMLParserDelegate {
    var root: _XMLNode?
    var stack = [_XMLNode]()
    var currentNode: _XMLNode?
    
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
    
    func parse(with data: Data) throws -> _XMLNode?  {
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
        stack = [_XMLNode]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let node = _XMLNode()
        node.name = elementName
        node.attributes = attributeDict
        stack.append(node)
        
        if let currentNode = currentNode {
            if currentNode.properties[elementName] != nil {
                currentNode.properties[elementName]?.append(node)
            } else {
                currentNode.properties[elementName] = [node]
            }
        }
        currentNode = node
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let poppedNode = stack.popLast(){
            if let content = poppedNode.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if content.isEmpty {
                    poppedNode.content = nil
                } else {
                    poppedNode.content = content
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
        currentNode?.content = (currentNode?.content ?? "") + string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentNode?.content = (currentNode?.content ?? "") + string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}

