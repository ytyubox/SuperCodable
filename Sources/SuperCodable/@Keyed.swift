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
public struct Keyed<Value> {
    // MARK: Lifecycle

    public init(_ key: String) {
        self.inner = Inner(key)
    }

    public init() {
        self.inner = Inner("")
    }

    // MARK: Public

    public var wrappedValue: Value {
        get {
            inner.value!
        }
        nonmutating set {
            inner.value = newValue
        }
    }

    // MARK: Private

    private final class Inner {
        // MARK: Lifecycle

        public init(_ key: String) {
            self.key = key
        }

        // MARK: Fileprivate

        fileprivate let key: String
        fileprivate var value: Value?
    }

    private let inner: Inner
}

// MARK: EncodableKey

extension Keyed: EncodableKey where Value: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        try encoding(for: inner.key, from: &container)
    }

    func encoding(for key: String, from container: inout EncodeContainer) throws {
        let codingKey = DynamicKey(key: key)
        try container.encodeIfPresent(wrappedValue, forKey: codingKey)
    }
}

// MARK: RunTimeEncodableKey

extension Keyed: RunTimeEncodableKey where Value: Encodable {
    public func shouldApplyRunTimeEncoding() -> Bool {
        inner.key.isEmpty
    }

    public func encodeValue(with key: String, from container: inout EncodeContainer) throws {
        try encoding(for: key, from: &container)
    }
}

// MARK: DecodableKey

extension Keyed: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        if inner.key.isEmpty {
            throw DecodableKeyError("key is missing")
        }
        try decoding(container, for: inner.key)
    }

    private func decoding(_ container: Keyed<Value>.DecodeContainer, for key: String) throws {
        let codingKey = DynamicKey(key: key)

        if let value = try container.decodeIfPresent(Value.self, forKey: codingKey) {
            inner.value = value
        }
    }
}

// MARK: RunTimeDecodableKey

extension Keyed: RunTimeDecodableKey where Value: Decodable {
    func shouldApplyRunTimeDecoding() -> Bool {
        inner.key.isEmpty
    }

    func decodeValue(with key: String, from container: DecodeContainer) throws {
        try decoding(container, for: key)
    }
}
