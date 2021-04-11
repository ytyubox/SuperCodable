//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - DecodableKey

public protocol DecodableKey {
    typealias DecodeContainer = KeyedDecodingContainer<DynamicKey>
    func decodeValue(from container: DecodeContainer) throws
}

// MARK: - RunTimeDecodableKey

protocol RunTimeDecodableKey: DecodableKey {
    func shouldApplyRunTimeDecoding() -> Bool
    func encodeValue(with key: String, from container: DecodeContainer) throws
}

// MARK: - DecodableKeyError

struct DecodableKeyError: LocalizedError {
    // MARK: Lifecycle

    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }

    // MARK: Internal

    var errorDescription: String?
}

// MARK: - SuperDecodable

public protocol SuperDecodable: Decodable {
    init()
}

public extension SuperDecodable {
    init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: DynamicKey.self)
        for child in Mirror(reflecting: self).children {
            guard let decodableKey = child.value as? DecodableKey else { continue }

            if let runTimeDecodable = decodableKey as? RunTimeDecodableKey,
               runTimeDecodable.shouldApplyRunTimeDecoding()
            {
                let key = child.label?.dropFirst() ?? ""
                try runTimeDecodable.encodeValue(with: String(key), from: container)
            } else {
                try decodableKey.decodeValue(from: container)
            }
        }
    }
}
