//
/*
 *		Created by 游宗諭 in 2021/4/16
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - Polymorphic

protocol Polymorphic: Codable {
    static var id: String { get }
}

extension Polymorphic {
    static var id: String {
        String(describing: Self.self)
    }
}

extension Encoder {
    func encode<ValueType>(_ value: ValueType) throws {
        guard let value = value as? Polymorphic else {
            throw PolymorphicCodableError.unableToRepresentAsPolymorphicForEncoding
        }
        var container = self.container(
            keyedBy: PolymorphicMetaContainerKeys.self
        )
        try container.encode(type(of: value).id, forKey: ._type)
        try value.encode(to: self)
    }
}

// MARK: - PolymorphicCodableError

enum PolymorphicCodableError: Error {
    case missingPolymorphicTypes
    case unableToFindPolymorphicType(String)
    case unableToCast(decoded: Polymorphic, into: String)
    case unableToRepresentAsPolymorphicForEncoding
}

// MARK: - PolymorphicMetaContainerKeys

enum PolymorphicMetaContainerKeys: CodingKey {
    case _type
}

extension Decoder {
    func decode<ExpectedType>(_ expectedType: ExpectedType.Type) throws -> ExpectedType {
        let container = try self.container(keyedBy: PolymorphicMetaContainerKeys.self)
        let typeID = try container.decode(String.self, forKey: ._type)

        guard let types = self.userInfo[.polymorphicTypes] as? [Polymorphic.Type] else {
            throw PolymorphicCodableError.missingPolymorphicTypes
        }

        let _matchingType = types.first { type in
            type.id == typeID
        }

        guard let matchingType = _matchingType else {
            throw PolymorphicCodableError.unableToFindPolymorphicType(typeID)
        }

        let _decoded = try matchingType.init(from: self)

        guard let decoded = _decoded as? ExpectedType else {
            throw PolymorphicCodableError.unableToCast(
                decoded: _decoded,
                into: String(describing: ExpectedType.self)
            )
        }
        return decoded
    }
}

extension CodingUserInfoKey {
    static var polymorphicTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.polymophicTypes")!
    }
}

// MARK: - PolymorphicValue

@propertyWrapper
struct PolymorphicValue<Value> {
    var wrappedValue: Value
}

// MARK: Codable

extension PolymorphicValue: Codable {
    init(from decoder: Decoder) throws {
        self.wrappedValue = try decoder.decode(Value.self)
    }

    func encode(to encoder: Encoder) throws {
        try encoder.encode(self.wrappedValue)
    }
}

// MARK: - UserRecord

struct UserRecord: Codable {
    let name: String

    @PolymorphicValue
    var pet: Animal
}

import XCTest

// MARK: - ATests

final class ATests: XCTestCase {
    func test() throws {
        let model = UserRecord(name: "A name", pet: Snake(name: "A Snake"))
        let data = try JSONEncoder().encode(model)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"name":"A name","pet":{"_type":"Snake","name":"A Snake"}}
            """#
        )
    }

    func testDecodeSnake() throws {
        let data = #"""
        {
          "name": "A name",
          "pet": {
            "_type": "Snake",
            "name": "A Snake"
          }
        }
        """#.data(using: .utf8)!
        let model = try makeDecoder().decode(UserRecord.self, from: data)
        XCTAssertEqual(model.name, "A name")
        let pet = try XCTUnwrap(model.pet as? Snake)
        XCTAssertEqual(pet.name, "A Snake")
    }
    
    func testDecodeDog() throws {
        let data = #"""
        {
          "name": "A name",
          "pet": {
            "_type": "Dog",
            "petName": "A dog"
          }
        }
        """#.data(using: .utf8)!
        let model = try makeDecoder().decode(UserRecord.self, from: data)
        XCTAssertEqual(model.name, "A name")
        let pet = try XCTUnwrap(model.pet as? Dog)
        XCTAssertEqual(pet.petName, "A dog")
    }

    func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.polymorphicTypes] = [
            Snake.self,
            Dog.self
        ]

        return decoder
    }
}

// MARK: - Animal

protocol Animal: Polymorphic {}

// MARK: - Snake

struct Snake: Animal {
    var name: String
}

// MARK: - Dog

struct Dog: Animal {
    var petName: String
}

