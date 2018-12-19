//
//  DateBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

struct DateBox: Equatable {
    typealias Unboxed = Date
    
    let unboxed: Unboxed
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    init?(secondsSince1970 string: String) {
        guard let seconds = TimeInterval(string) else {
            return nil
        }
        self.init(Date(timeIntervalSince1970: seconds))
    }
    
    init?(millisecondsSince1970 string: String) {
        guard let milliseconds = TimeInterval(string) else {
            return nil
        }
        self.init(Date(timeIntervalSince1970: milliseconds / 1000.0))
    }
    
    init?(iso8601 string: String) {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            guard let date = _iso8601Formatter.date(from: string) else {
                return nil
            }
            self.init(date)
        } else {
            fatalError("ISO8601DateFormatter is unavailable on this platform.")
        }
    }
    
    init?(xmlString: String, formatter: DateFormatter) {
        guard let date = formatter.date(from: xmlString) else {
            return nil
        }
        self.init(date)
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension DateBox: Box {
    var isNull: Bool {
        return false
    }
    
    var isFragment: Bool {
        return true
    }
    
    var xmlString: String? {
        return self.unboxed.description
    }
}

extension DateBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
