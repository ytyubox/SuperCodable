//
/* 
 *		Created by 游宗諭 in 2021/4/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation

@propertyWrapper
public struct OptionalKeyed<Value> {
    public init(_ key: String) {
        self.inner = Inner(key)
    }
    public init(wrappedValue: Value?, _ key: String) {
        self.inner = Inner(key)
        inner.value = .already(wrappedValue)
    }

    public init() {
        self.inner = Inner("")
    }
    public init(wrappedValue: Value?) {
        self.inner = Inner("")
        inner.value = .already(wrappedValue)
    }

    public var wrappedValue: Value? {
        get {
            switch inner.value {
            case .yet:
                fatalError("did not decode")
            case let .already(v):
                return v
            case .none:
                return nil
            }
        }
        nonmutating set {
            inner.value = .already(newValue)
        }
    }

    private final class Inner {
        public init(_ key: String) {
            self.key = key
        }

        fileprivate let key: String
        fileprivate var value: Lazy<Value?> = .yet
    }

    private let inner: Inner
}

// MARK: EncodableKey

extension OptionalKeyed: EncodableKey where Value: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        try encoding(for: inner.key, from: &container)
    }

    func encoding(for key: String, from container: inout EncodeContainer) throws {
        let codingKey = DynamicKey(key: key)
        try container.encodeIfPresent(wrappedValue, forKey: codingKey)
    }
}

// MARK: RunTimeEncodableKey

extension OptionalKeyed: RunTimeEncodableKey where Value: Encodable {
    public func shouldApplyRunTimeEncoding() -> Bool {
        inner.key.isEmpty
    }

    public func encodeValue(with key: String, from container: inout EncodeContainer) throws {
        try encoding(for: key, from: &container)
    }
}

// MARK: DecodableKey

extension OptionalKeyed: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        if inner.key.isEmpty {
            throw DecodableKeyError("key is missing")
        }
        try decoding(container, for: inner.key)
    }

    private func decoding(_ container: Keyed<Value>.DecodeContainer, for key: String) throws {
        let codingKey = DynamicKey(key: key)

        if let value = try container.decodeIfPresent(Value.self, forKey: codingKey) {
            inner.value = .already(value)
        }
        else {
            inner.value = .none
        }
    }
}

// MARK: RunTimeDecodableKey

extension OptionalKeyed: RunTimeDecodableKey where Value: Decodable {
    func shouldApplyRunTimeDecoding() -> Bool {
        inner.key.isEmpty
    }

    func decodeValue(with key: String, from container: DecodeContainer) throws {
        try decoding(container, for: key)
    }
}
