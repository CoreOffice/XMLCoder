//
//  DataBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/19/18.
//

import Foundation

struct DataBox: Equatable {
    typealias Unboxed = Data
    
    let unboxed: Unboxed
    
    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }
    
    init?(base64 string: String) {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        self.init(data)
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
}

extension DataBox: Box {
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

extension DataBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
