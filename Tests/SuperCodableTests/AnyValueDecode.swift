//
/* 
 *		Created by 游宗諭 in 2021/9/14
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 12.0
 */

import XCTest
import SuperCodable

final class AnyValueTests: XCTestCase {
    func test() throws {
        let data =
            #"""
            [
                {
                    "id": "0",
                },
                {
                    "id": 1,
                },
                {
                    "id": "abc",
                },
                {
                    "id": true,
                },
            ]
            """#.data(using: .utf8)!
        let sut = try! JSONDecoder().decode([AnyValueJSON].self, from: data)
        XCTAssertEqual(sut.count,
                       4)
        XCTAssertEqual(
            sut.map(\.id),
            [0, 1, 0, 1])
       
    }
}

private struct AnyValueJSON: SuperCodable {
    @KeyedTransform(IDTransform)
    var id:Int
}

let IDTransform = SCTransformOf<Int, AnyValue> {
    (anyValue) -> Int in
    switch anyValue {
    case let .string(obj): return Int(atoi(obj))
    case let .bool(obj): return obj ? 1 :0
    case let .int(obj): return obj
    case let .double(obj): return Int(obj)
    case let .dictionary(obj): return 0
    case let .array(obj): return 0
    case .null: return 0
    }
} toEncoder: { (int) -> AnyValue in
    return .int(int)
}

public enum AnyValue: Equatable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case dictionary([String: AnyValue])
    case array([AnyValue])
    case null
}

extension AnyValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode([String: AnyValue].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode([AnyValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "Cannot decode AnyValue")
            throw DecodingError.typeMismatch(AnyValue.self, context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .dictionary(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
