// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 30/12/2018.
//

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
public protocol XMLDecodableSequence {
    init()
}

extension Array: XMLDecodableSequence {}

extension Dictionary: XMLDecodableSequence {}

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
protocol AnyOptional {
    init()
}

extension Optional: AnyOptional {
    init() {
        self = nil
    }
}
