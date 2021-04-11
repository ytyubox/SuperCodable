//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - EncodableKey

public protocol EncodableKey {
    typealias EncodeContainer = KeyedEncodingContainer<DynamicKey>
    func encodeValue(from container: inout EncodeContainer) throws
}

// MARK: - SuperEncodable

public protocol SuperEncodable: Encodable {}
public extension SuperEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        for child in Mirror(reflecting: self).children {
            guard let encodableKey = child.value as? EncodableKey else { continue }
            try encodableKey.encodeValue(from: &container)
        }
    }
}
