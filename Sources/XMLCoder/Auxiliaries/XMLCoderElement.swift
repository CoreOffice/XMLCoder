//
//  XMLCoderElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

struct XMLCoderElement: Equatable {
    static let attributesKey = "___ATTRIBUTES"
    static let escapedCharacterSet = [
        ("&", "&amp;"),
        ("<", "&lt;"),
        (">", "&gt;"),
        ("'", "&apos;"),
        ("\"", "&quot;"),
    ]

    var key: String
    var value: String?
    var elements: [XMLCoderElement] = []
    var attributes: [String: String] = [:]

    init(
        key: String,
        value: String? = nil,
        elements: [XMLCoderElement] = [],
        attributes: [String: String] = [:]
    ) {
        self.key = key
        self.value = value
        self.elements = elements
        self.attributes = attributes
    }

    mutating func append(value string: String) {
        guard value != nil else {
            value = string
            return
        }
        value?.append(string)
    }

    mutating func append(element: XMLCoderElement, forKey key: String) {
        elements.append(element)
    }

    func transformToBoxTree() -> KeyedBox {
        let attributes = KeyedStorage(self.attributes.map { key, value in
            (key: key, value: StringBox(value) as SimpleBox)
        })
        let storage = KeyedStorage<String, Box>()
        var elements = self.elements.reduce(storage) { $0.merge(element: $1) }

        // Handle attributed unkeyed value <foo attr="bar">zap</foo>
        // Value should be zap. Detect only when no other elements exist
        if elements.isEmpty, let value = value {
            elements.append(StringBox(value), at: "value")
        }
        let keyedBox = KeyedBox(elements: elements, attributes: attributes)

        return keyedBox
    }

    func toXMLString(with header: XMLHeader? = nil,
                     withCDATA cdata: Bool,
                     formatting: XMLEncoder.OutputFormatting,
                     ignoreEscaping _: Bool = false) -> String {
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
        from keyValuePairs: [(key: String, value: String)],
        into string: inout String
    ) {
        for (key, value) in keyValuePairs {
            string += attributeString(key: key, value: value)
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
                                    prettyPrinted: prettyPrinted)
        }
    }

    fileprivate func formatSortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(
            from: attributes.sorted(by: { $0.key < $1.key }), into: &string
        )
    }

    fileprivate func formatUnsortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(
            from: attributes.map { (key: $0, value: $1) }, into: &string
        )
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
        formatting: XMLEncoder.OutputFormatting,
        ignoreEscaping: Bool = false
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

        if let value = value {
            if !key.isEmpty {
                string += ">"
            }
            if !ignoreEscaping {
                string += (cdata == true ? "<![CDATA[\(value)]]>" :
                    "\(value.escape(XMLCoderElement.escapedCharacterSet))")
            } else {
                string += "\(value)"
            }

            if !key.isEmpty {
                string += "</\(key)>"
            }
        } else if !elements.isEmpty {
            string += prettyPrinted ? ">\n" : ">"
            formatXMLElements(formatting, &string, level, cdata, prettyPrinted)

            string += indentation
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
        self.init(key: key, elements: box.map {
            XMLCoderElement(key: key, box: $0)
        })
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

        let attributes: [String: String] = Dictionary(
            uniqueKeysWithValues: box.attributes.compactMap { key, box in
                guard let value = box.xmlString() else {
                    return nil
                }
                return (key, value)
            }
        )

        self.init(key: key, elements: elements, attributes: attributes)
    }

    init(key: String, box: SimpleBox) {
        self.init(key: key)
        value = box.xmlString()
    }

    init(key: String, box: Box) {
        switch box {
        case let sharedUnkeyedBox as SharedBox<UnkeyedBox>:
            self.init(key: key, box: sharedUnkeyedBox.unboxed)
        case let sharedKeyedBox as SharedBox<KeyedBox>:
            self.init(key: key, box: sharedKeyedBox.unboxed)
        case let unkeyedBox as UnkeyedBox:
            self.init(key: key, box: unkeyedBox)
        case let keyedBox as KeyedBox:
            self.init(key: key, box: keyedBox)
        case let simpleBox as SimpleBox:
            self.init(key: key, box: simpleBox)
        case let box:
            preconditionFailure("Unclassified box: \(type(of: box))")
        }
    }
}
