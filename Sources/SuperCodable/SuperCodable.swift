// MARK: - DynamicCodingKeys

public struct DynamicCodingKeys: CodingKey {
    // MARK: Lifecycle

    init(key: String) {
        self.stringValue = key
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    // MARK: Public

    public var stringValue: String
    public var intValue: Int?
}

// MARK: - EncodableKey

public protocol EncodableKey {
    typealias EncodeContainer = KeyedEncodingContainer<DynamicCodingKeys>
    func encodeValue(from container: inout EncodeContainer) throws
}

// MARK: - SuperEncodable

public protocol SuperEncodable: Encodable {}
public extension SuperEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for child in Mirror(reflecting: self).children {
            guard let encodableKey = child.value as? EncodableKey else { continue }
            try encodableKey.encodeValue(from: &container)
        }
    }
}

// MARK: - DecodableKey

public protocol DecodableKey {
    typealias DecodeContainer = KeyedDecodingContainer<DynamicCodingKeys>
    func decodeValue(from container: DecodeContainer) throws
}

// MARK: - SuperDecodable

public protocol SuperDecodable: Decodable {
    init()
}

public extension SuperDecodable {
    init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        for child in Mirror(reflecting: self).children {
            guard let decodableKey = child.value as? DecodableKey else { continue }
            try decodableKey.decodeValue(from: container)
        }
    }
}

public typealias SuperCodable = SuperEncodable & SuperDecodable

// MARK: - Keyed

@propertyWrapper
public final class Keyed<Value> {
    // MARK: Lifecycle

    public init(_ key: String) {
        self.key = key
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
    private var value: Value?

    // MARK: Internal

    let key: String
}

// MARK: EncodableKey

extension Keyed: EncodableKey where Value: Encodable {
    public func encodeValue(from container: inout EncodeContainer) throws {
        let codingKey = DynamicCodingKeys(key: key)
        try container.encodeIfPresent(wrappedValue, forKey: codingKey)
    }
}

// MARK: DecodableKey

extension Keyed: DecodableKey where Value: Decodable {
    public func decodeValue(from container: DecodeContainer) throws {
        let codingKey = DynamicCodingKeys(key: key)

        if let value = try container.decodeIfPresent(Value.self, forKey: codingKey) {
            wrappedValue = value
        }
    }
}
