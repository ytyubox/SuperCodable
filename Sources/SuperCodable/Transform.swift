//
/*
 *		Created by 游宗諭 in 2021/4/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - FATransformDecoder

protocol FATransformDecoder {
    associatedtype Out
    associatedtype In
    func transformFromDecoder(_ value: Any) throws -> Out?
}

// MARK: - FATransformTypeEncoder

protocol FATransformTypeEncoder {
    associatedtype Out
    associatedtype In
    func transformToEncoder(_ container: inout EncodableKey.EncodeContainer, _ value: Out, key: String) throws
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

public class FATransformOf<OutType, InType> {
    // MARK: Lifecycle

    public init(fromDecoder: @escaping (InType) throws -> OutType,
                toEncoder: @escaping (OutType) throws -> InType)
    {
        self.fromDecoder = fromDecoder
        self.toEncoder = toEncoder
    }

    // MARK: Public

    public typealias Out = OutType
    public typealias In = InType

    // MARK: Private

    private let fromDecoder: (InType) throws -> OutType
    private let toEncoder: (OutType) throws -> InType
}

// MARK: FATransformTypeEncoder

extension FATransformOf: FATransformTypeEncoder where In: Encodable {
    // MARK: Internal

    func transformToEncoder(_ container: inout KeyedEncodingContainer<DynamicKey>,
                            _ value: Out,
                            key: String) throws
    {
        let inOubject = try toEncoder(value)
        let codingKey = DynamicKey(key: key)
        try? container.encodeIfPresent(inOubject, forKey: codingKey)
    }
}

// MARK: FATransformDecoder

extension FATransformOf: FATransformDecoder where In: Decodable {
    public func transformFromDecoder(_ value: Any) throws -> OutType? {
        guard let v = value as? InType else {
            throw FATransformOfError("expect value is \(InType.self), but found \(type(of: value))")
        }
        return try fromDecoder(v)
    }
}

// MARK: - KeyedTransform

@propertyWrapper

public struct KeyedTransform<In, Out> {
    // MARK: Lifecycle

    public init(_ key: String,
                _ transform: FATransformOf<Out, In>)
    {
        self.inner = Inner(key, transform)
    }

    public init(
        _ transform: FATransformOf<Out, In>)
    {
        self.inner = Inner("", transform)
    }

    // MARK: Public

    public var wrappedValue: Out {
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
                    _ transform: FATransformOf<Out, In>)
        {
            self.key = key
            self.transform = transform
        }

        // MARK: Internal

        let key: String
        var transform: FATransformOf<Out, In>

        var value: Out?
    }

    // MARK: Private

    private let inner: Inner
}

// MARK: EncodableKey

extension KeyedTransform: EncodableKey where In: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        try inner.transform.transformToEncoder(&container, wrappedValue, key: inner.key)
    }
}

// MARK: RunTimeEncodableKey

extension KeyedTransform: RunTimeEncodableKey where In: Encodable {
    public func shouldApplyRunTimeEncoding() -> Bool {
        inner.key.isEmpty
    }

    public func encodeValue(with key: String, from container: inout EncodeContainer) throws {
        try inner.transform.transformToEncoder(&container, wrappedValue, key: key)
    }
}

// MARK: DecodableKey

extension KeyedTransform: DecodableKey where In: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        try decoding(with: inner.key, from: container)
    }

    private func decoding(with key: String, from container: DecodeContainer) throws {
        let codingKey = DynamicKey(key: key)
        if let value = try container.decodeIfPresent(In.self, forKey: codingKey) {
            inner.value = try inner.transform.transformFromDecoder(value)
        }
        else {
            throw DecodableKeyError(#"key `\#(key)` not found"#)
        }
    }
}

// MARK: RunTimeDecodableKey

extension KeyedTransform: RunTimeDecodableKey where In: Decodable {
    func shouldApplyRunTimeDecoding() -> Bool {
        inner.key.isEmpty
    }

    func decodeValue(with key: String, from container: DecodeContainer) throws {
        try decoding(with: key, from: container)
    }
}
