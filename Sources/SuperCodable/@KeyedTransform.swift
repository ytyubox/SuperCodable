//
/*
 *		Created by 游宗諭 in 2021/4/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - SCTransformFromDecoder

protocol SCTransformFromDecoder {
    associatedtype Output
    associatedtype FromDecoderType
    func transformFromDecoder(
        _ container: DecodableKey.DecodeContainer,
        key: String
    ) throws -> Output
}

// MARK: - SCTransformIntoEncoder

protocol SCTransformIntoEncoder {
    associatedtype EncoderOut
    func transformToEncoder(
        _ container: inout EncodableKey.EncodeContainer,
        _ value: EncoderOut,
        key: String
    ) throws
}

// MARK: - FATransformOfError

struct FATransformOfError: LocalizedError {
    // MARK: Lifecycle

    internal init(_ errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }

    // MARK: Internal

    var errorDescription: String?
}

// MARK: - SCTransformOf

public class SCTransformOf<Value, RelateType> {
    // MARK: Lifecycle

    public init(fromDecoder: @escaping (RelateType) throws -> Value,
                toEncoder: @escaping (Value) throws -> RelateType)
    {
        self.fromDecoder = fromDecoder
        self.toEncoder = toEncoder
    }

    // MARK: Private

    private let fromDecoder: (RelateType) throws -> Value
    private let toEncoder: (Value) throws -> RelateType
}

// MARK: SCTransformIntoEncoder

extension SCTransformOf: SCTransformIntoEncoder where RelateType: Encodable {
    func transformToEncoder(_ container: inout KeyedEncodingContainer<DynamicKey>,
                            _ value: Value,
                            key: String) throws
    {
        let toEncoderValue = try toEncoder(value)
        let codingKey = DynamicKey(key: key)
        try container.encodeIfPresent(toEncoderValue, forKey: codingKey)
    }
}

// MARK: SCTransformFromDecoder

extension SCTransformOf: SCTransformFromDecoder where RelateType: Decodable {
    typealias Output = Value

    typealias FromDecoderType = RelateType

    func transformFromDecoder(
        _ container: DecodableKey.DecodeContainer,
        key: String
    ) throws -> Value {
        let codingKey = DynamicKey(key: key)
        if let value = try container.decodeIfPresent(RelateType.self, forKey: codingKey) {
            return try fromDecoder(value)
        }
        else {
            throw DecodableKeyError(#"key `\#(key)` not found"#)
        }
    }
}

// MARK: - KeyedTransform

@propertyWrapper
public struct KeyedTransform<Value, RelateType> {
    // MARK: Lifecycle

    public init(_ key: String,
                _ transform: SCTransformOf<RelateType, Value>)
    {
        self.inner = Inner(key, transform)
    }

    public init(
        _ transform: SCTransformOf<RelateType, Value>)
    {
        self.inner = Inner("", transform)
    }

    // MARK: Public

    public var wrappedValue: RelateType {
        get {
            inner.value!
        }
        nonmutating set {
            inner.value = newValue
        }
    }

    // MARK: Fileprivate

    fileprivate final class Inner {
        // MARK: Lifecycle

        public init(_ key: String,
                    _ transform: SCTransformOf<RelateType, Value>)
        {
            self.key = key
            self.transform = transform
        }

        // MARK: Internal

        let key: String
        var transform: SCTransformOf<RelateType, Value>

        var value: RelateType?
    }

    // MARK: Private

    private let inner: Inner
}

// MARK: EncodableKey

extension KeyedTransform: EncodableKey where Value: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        try encoding(key: inner.key, from: &container)
    }

    private func encoding(key: String, from container: inout EncodeContainer) throws {
        try inner.transform.transformToEncoder(&container, wrappedValue, key: key)
    }
}

// MARK: RunTimeEncodableKey

extension KeyedTransform: RunTimeEncodableKey where Value: Encodable {
    public func shouldApplyRunTimeEncoding() -> Bool {
        inner.key.isEmpty
    }

    public func encodeValue(with key: String, from container: inout EncodeContainer) throws {
        try encoding(key: key, from: &container)
    }
}

// MARK: DecodableKey

extension KeyedTransform: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        try decoding(with: inner.key, from: container)
    }

    private func decoding(with key: String, from container: DecodeContainer) throws {
        wrappedValue = try inner.transform.transformFromDecoder(container, key: key)
    }
}

// MARK: RunTimeDecodableKey

extension KeyedTransform: RunTimeDecodableKey where Value: Decodable {
    func shouldApplyRunTimeDecoding() -> Bool {
        inner.key.isEmpty
    }

    func decodeValue(with key: String, from container: DecodeContainer) throws {
        try decoding(with: key, from: container)
    }
}
