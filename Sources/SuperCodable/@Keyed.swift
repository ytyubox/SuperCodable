//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - Keyed

@propertyWrapper
public final class Keyed<Value> {
    // MARK: Lifecycle

    public init(_ key: String) {
        self.key = key
    }

    public init() {
        self.key = ""
    }

    // MARK: Public

    public var wrappedValue: Value {
        get {
            value!
        }
        set {
            value = newValue
        }
    }

    // MARK: Private

    private let key: String

    private var value: Value?
}

// MARK: EncodableKey

extension Keyed: EncodableKey where Value: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        let codingKey = DynamicKey(key: key)
        try container.encodeIfPresent(wrappedValue, forKey: codingKey)
    }
}

// MARK: DecodableKey

extension Keyed: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        if key.isEmpty {
            throw DecodableKeyError("key is missing")
        }
        try decoding(container, for: key)
    }

    private func decoding(_ container: Keyed<Value>.DecodeContainer, for key: String) throws {
        let codingKey = DynamicKey(key: key)

        if let value = try container.decodeIfPresent(Value.self, forKey: codingKey) {
            self.value = value
        }
    }
}

// MARK: RunTimeDecodableKey

extension Keyed: RunTimeDecodableKey where Value: Decodable {
    func shouldApplyRunTimeDecoding() -> Bool {
        key.isEmpty
    }

    func decodeValue(with key: String, from container: DecodeContainer) throws {
        try decoding(container, for: key)
    }
}
