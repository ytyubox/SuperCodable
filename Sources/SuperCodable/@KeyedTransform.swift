//
/*
 *		Created by 游宗諭 in 2021/4/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - SCTransformDecoder

protocol SCTransformFromDecoder {
    associatedtype DecoderOut
    func transformFromDecoder(_ value: Any) throws -> DecoderOut
}

// MARK: - SCTransformEncoder

protocol SCTransformIntoEncoder {
    associatedtype EncoderOut
    func transformToEncoder(_ container: inout EncodableKey.EncodeContainer, _ value: EncoderOut, key: String) throws
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

// MARK: - FATransformOf

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

// MARK: SCTransformEncoder

extension SCTransformOf: SCTransformIntoEncoder where RelateType: Encodable {
    // MARK: Internal

    func transformToEncoder(_ container: inout KeyedEncodingContainer<DynamicKey>,
                            _ value: Value,
                            key: String) throws
    {
        let inOubject = try toEncoder(value)
        let codingKey = DynamicKey(key: key)
        try container.encodeIfPresent(inOubject, forKey: codingKey)
    }
}

// MARK: SCTransformDecoder

extension SCTransformOf: SCTransformFromDecoder where RelateType: Decodable {
    public func transformFromDecoder(_ value: Any) throws -> Value {
        guard let v = value as? RelateType else {
            throw FATransformOfError("expect value is \(RelateType.self), but found \(type(of: value))")
        }
        return try fromDecoder(v)
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
        try inner.transform.transformToEncoder(&container, wrappedValue, key: inner.key)
    }
}

// MARK: RunTimeEncodableKey

extension KeyedTransform: RunTimeEncodableKey where Value: Encodable {
    public func shouldApplyRunTimeEncoding() -> Bool {
        inner.key.isEmpty
    }

    public func encodeValue(with key: String, from container: inout EncodeContainer) throws {
        try inner.transform.transformToEncoder(&container, wrappedValue, key: key)
    }
}

// MARK: DecodableKey

extension KeyedTransform: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        try decoding(with: inner.key, from: container)
    }

    private func decoding(with key: String, from container: DecodeContainer) throws {
        let codingKey = DynamicKey(key: key)
        if let value = try container.decodeIfPresent(Value.self, forKey: codingKey) {
            inner.value = try inner.transform.transformFromDecoder(value)
        }
        else {
            throw DecodableKeyError(#"key `\#(key)` not found"#)
        }
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
