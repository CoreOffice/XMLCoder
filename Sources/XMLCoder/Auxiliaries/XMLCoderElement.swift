//
//  XMLCoderElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

struct Attribute: Equatable {
    let key: String
    let value: String
}

struct XMLCoderElement: Equatable {
    private static let attributesKey = "___ATTRIBUTES"
    private static let escapedCharacterSet = [
        ("&", "&amp;"),
        ("<", "&lt;"),
        (">", "&gt;"),
        ("'", "&apos;"),
        ("\"", "&quot;"),
    ]

    let key: String
    private(set) var stringValue: String?
    private(set) var elements: [XMLCoderElement] = []
    private(set) var attributes: [Attribute] = []
    private(set) var containsTextNodes: Bool = false

    var isStringNode: Bool {
        return key == ""
    }

    var isCDATANode: Bool {
        return key == "#CDATA"
    }

    var isTextNode: Bool {
        return isStringNode || isCDATANode
    }

    init(
        key: String,
        elements: [XMLCoderElement] = [],
        attributes: [Attribute] = []
    ) {
        self.key = key
        stringValue = nil
        self.elements = elements
        self.attributes = attributes
    }

    init(
        key: String,
        stringValue string: String,
        attributes: [Attribute] = []
    ) {
        self.key = key
        elements = [XMLCoderElement(stringValue: string)]
        self.attributes = attributes
        containsTextNodes = true
    }

    init(
        key: String,
        cdataValue string: String,
        attributes: [Attribute] = []
    ) {
        self.key = key
        elements = [XMLCoderElement(cdataValue: string)]
        self.attributes = attributes
        containsTextNodes = true
    }

    init(stringValue string: String) {
        key = ""
        stringValue = string
    }

    init(cdataValue string: String) {
        key = "#CDATA"
        stringValue = string
    }

    mutating func append(element: XMLCoderElement, forKey key: String) {
        elements.append(element)
        containsTextNodes = containsTextNodes || element.isTextNode
    }

    mutating func append(string: String) {
        if elements.last?.isTextNode == true {
            let oldValue = elements[elements.count - 1].stringValue ?? ""
            elements[elements.count - 1].stringValue = oldValue + string
        } else {
            elements.append(XMLCoderElement(stringValue: string))
        }
        containsTextNodes = true
    }

    mutating func append(cdata string: String) {
        if elements.last?.isCDATANode == true {
            let oldValue = elements[elements.count - 1].stringValue ?? ""
            elements[elements.count - 1].stringValue = oldValue + string
        } else {
            elements.append(XMLCoderElement(cdataValue: string))
        }
        containsTextNodes = true
    }

    func transformToBoxTree() -> Box {
        if isTextNode {
            return StringBox(stringValue!)
        }

        let attributes = KeyedStorage(self.attributes.map { attribute in
            (key: attribute.key, value: StringBox(attribute.value) as SimpleBox)
        })
        let storage = KeyedStorage<String, Box>()
        let elements = self.elements.reduce(storage) { $0.merge(element: $1) }
        return KeyedBox(elements: elements, attributes: attributes)
    }

    func toXMLString(with header: XMLHeader? = nil,
                     withCDATA cdata: Bool,
                     formatting: XMLEncoder.OutputFormatting) -> String {
        if let header = header, let headerXML = header.toXML() {
            return headerXML + _toXMLString(withCDATA: cdata, formatting: formatting)
        }
        return _toXMLString(withCDATA: cdata, formatting: formatting)
    }

    private func formatUnsortedXMLElements(
        _ string: inout String,
        _ level: Int,
        _ cdata: Bool,
        _ formatting: XMLEncoder.OutputFormatting,
        _ prettyPrinted: Bool
    ) {
        formatXMLElements(
            from: elements,
            into: &string,
            at: level,
            cdata: cdata,
            formatting: formatting,
            prettyPrinted: prettyPrinted
        )
    }

    fileprivate func elementString(
        for element: XMLCoderElement,
        at level: Int,
        cdata: Bool,
        formatting: XMLEncoder.OutputFormatting,
        prettyPrinted: Bool
    ) -> String {
        if let stringValue = element.stringValue {
            if element.isCDATANode || cdata {
                return "<![CDATA[\(stringValue)]]>"
            } else {
                return stringValue.escape(XMLCoderElement.escapedCharacterSet)
            }
        }

        var string = ""
        string += element._toXMLString(
            indented: level + 1, withCDATA: cdata, formatting: formatting
        )
        string += prettyPrinted ? "\n" : ""
        return string
    }

    fileprivate func formatSortedXMLElements(
        _ string: inout String,
        _ level: Int,
        _ cdata: Bool,
        _ formatting: XMLEncoder.OutputFormatting,
        _ prettyPrinted: Bool
    ) {
        formatXMLElements(from: elements.sorted { $0.key < $1.key },
                          into: &string,
                          at: level,
                          cdata: cdata,
                          formatting: formatting,
                          prettyPrinted: prettyPrinted)
    }

    fileprivate func attributeString(key: String, value: String) -> String {
        return " \(key)=\"\(value.escape(XMLCoderElement.escapedCharacterSet))\""
    }

    fileprivate func formatXMLAttributes(
        from attributes: [Attribute],
        into string: inout String
    ) {
        for attribute in attributes {
            string += attributeString(key: attribute.key, value: attribute.value)
        }
    }

    fileprivate func formatXMLElements(
        from elements: [XMLCoderElement],
        into string: inout String,
        at level: Int,
        cdata: Bool,
        formatting: XMLEncoder.OutputFormatting,
        prettyPrinted: Bool
    ) {
        for element in elements {
            string += elementString(for: element,
                                    at: level,
                                    cdata: cdata,
                                    formatting: formatting,
                                    prettyPrinted: prettyPrinted && !containsTextNodes)
        }
    }

    fileprivate func formatSortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(
            from: attributes.sorted(by: { $0.key < $1.key }), into: &string
        )
    }

    fileprivate func formatUnsortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(from: attributes, into: &string)
    }

    private func formatXMLAttributes(
        _ formatting: XMLEncoder.OutputFormatting,
        _ string: inout String
    ) {
        if formatting.contains(.sortedKeys) {
            formatSortedXMLAttributes(&string)
            return
        }
        formatUnsortedXMLAttributes(&string)
    }

    private func formatXMLElements(
        _ formatting: XMLEncoder.OutputFormatting,
        _ string: inout String,
        _ level: Int,
        _ cdata: Bool,
        _ prettyPrinted: Bool
    ) {
        if formatting.contains(.sortedKeys) {
            formatSortedXMLElements(
                &string, level, cdata, formatting, prettyPrinted
            )
            return
        }
        formatUnsortedXMLElements(
            &string, level, cdata, formatting, prettyPrinted
        )
    }

    private func _toXMLString(
        indented level: Int = 0,
        withCDATA cdata: Bool,
        formatting: XMLEncoder.OutputFormatting
    ) -> String {
        let prettyPrinted = formatting.contains(.prettyPrinted)
        let indentation = String(
            repeating: " ", count: (prettyPrinted ? level : 0) * 4
        )
        var string = indentation

        if !key.isEmpty {
            string += "<\(key)"
        }

        formatXMLAttributes(formatting, &string)

        if !elements.isEmpty {
            let prettyPrintElements = prettyPrinted && !containsTextNodes
            if !key.isEmpty {
                string += prettyPrintElements ? ">\n" : ">"
            }
            formatXMLElements(formatting, &string, level, cdata, prettyPrintElements)

            if prettyPrintElements { string += indentation }
            if !key.isEmpty {
                string += "</\(key)>"
            }
        } else {
            string += " />"
        }

        return string
    }
}

// MARK: - Convenience Initializers

extension XMLCoderElement {
    init(key: String, box: UnkeyedBox) {
        if let containsChoice = box as? [ChoiceBox] {
            self.init(key: key, elements: containsChoice.map {
                XMLCoderElement(key: $0.key, box: $0.element)
            })
        } else {
            self.init(key: key, elements: box.map { XMLCoderElement(key: key, box: $0) })
        }
    }

    init(key: String, box: ChoiceBox) {
        self.init(key: key, elements: [XMLCoderElement(key: box.key, box: box.element)])
    }

    init(key: String, box: KeyedBox) {
        var elements: [XMLCoderElement] = []

        for (key, box) in box.elements {
            let fail = {
                preconditionFailure("Unclassified box: \(type(of: box))")
            }

            switch box {
            case let sharedUnkeyedBox as SharedBox<UnkeyedBox>:
                let box = sharedUnkeyedBox.unboxed
                elements.append(contentsOf: box.map {
                    XMLCoderElement(key: key, box: $0)
                })
            case let unkeyedBox as UnkeyedBox:
                // This basically injects the unkeyed children directly into self:
                elements.append(contentsOf: unkeyedBox.map {
                    XMLCoderElement(key: key, box: $0)
                })
            case let sharedKeyedBox as SharedBox<KeyedBox>:
                let box = sharedKeyedBox.unboxed
                elements.append(XMLCoderElement(key: key, box: box))
            case let keyedBox as KeyedBox:
                elements.append(XMLCoderElement(key: key, box: keyedBox))
            case let simpleBox as SimpleBox:
                elements.append(XMLCoderElement(key: key, box: simpleBox))
            default:
                fail()
            }
        }

        let attributes: [Attribute] = box.attributes.compactMap { key, box in
            guard let value = box.xmlString else {
                return nil
            }
            return Attribute(key: key, value: value)
        }

        self.init(key: key, elements: elements, attributes: attributes)
    }

    init(key: String, box: SimpleBox) {
        if let value = box.xmlString {
            self.init(key: key, stringValue: value)
        } else {
            self.init(key: key)
        }
    }

    init(key: String, box: Box) {
        switch box {
        case let sharedUnkeyedBox as SharedBox<UnkeyedBox>:
            self.init(key: key, box: sharedUnkeyedBox.unboxed)
        case let sharedKeyedBox as SharedBox<KeyedBox>:
            self.init(key: key, box: sharedKeyedBox.unboxed)
        case let sharedChoiceBox as SharedBox<ChoiceBox>:
            self.init(key: key, box: sharedChoiceBox.unboxed)
        case let unkeyedBox as UnkeyedBox:
            self.init(key: key, box: unkeyedBox)
        case let keyedBox as KeyedBox:
            self.init(key: key, box: keyedBox)
        case let choiceBox as ChoiceBox:
            self.init(key: key, box: choiceBox)
        case let simpleBox as SimpleBox:
            self.init(key: key, box: simpleBox)
        case let box:
            preconditionFailure("Unclassified box: \(type(of: box))")
        }
    }
}
