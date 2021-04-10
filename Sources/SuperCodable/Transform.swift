//
/*
 *		Created by 游宗諭 in 2021/4/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - FATransformType

protocol FATransformType {
    associatedtype Out
    associatedtype In: Encodable
    func transformFromDecoder(_ value: Any) throws -> Out?
    func transformToEncoder(_ container: inout EncodableKey.EncodeContainer, _ value: Out, key: String) throws
}

// MARK: - FATransformOf
struct FATransformOfError:LocalizedError {
    internal init(_ errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
    
    var errorDescription: String?
}
public class FATransformOf<OutType, InType: Encodable>: FATransformType {
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

    public func transformFromDecoder(_ value: Any) throws -> OutType? {
        guard let v = value as? InType else {
            throw FATransformOfError("expect value is \(InType.self), but found \(type(of: value))")
        }
        return try fromDecoder(v)
    }

    // MARK: Internal

    func transformToEncoder(_ container: inout KeyedEncodingContainer<DynamicCodingKeys>,
                         _ value: Out,
                         key: String) throws
    {
        let inOubject = try toEncoder(value)
        let codingKey = DynamicCodingKeys(key: key)
        try? container.encodeIfPresent(inOubject, forKey: codingKey)
    }

    // MARK: Private

    private let fromDecoder: (InType) throws -> OutType
    private let toEncoder: (OutType) throws -> InType
}

// MARK: - KeyedTransform

@propertyWrapper
public final class KeyedTransform<In: Codable, Out: Codable> {
    // MARK: Lifecycle

    public init(_ key: String,
                _ transform: FATransformOf<Out, In>)
    {
        self.key = key
        self.transform = transform
    }

    // MARK: Public

    public var wrappedValue: Out {
        get {
            value!
        }
        set {
            value = newValue
        }
    }

    // MARK: Internal

    let key: String
    var transform: FATransformOf<Out, In>

    // MARK: Private

    private var value: Out?
}

// MARK: EncodableKey

extension KeyedTransform: EncodableKey {
    public func encodeValue(from container: inout EncodeContainer) throws {
        try transform.transformToEncoder(&container, wrappedValue, key: key)
    }
}

// MARK: DecodableKey

extension KeyedTransform: DecodableKey {
    public func decodeValue(from container: DecodeContainer) throws {
        let codingKey = DynamicCodingKeys(key: key)
        if let value = try container.decodeIfPresent(In.self, forKey: codingKey) {
            self.value = try transform.transformFromDecoder(value)
        }
    }
}
