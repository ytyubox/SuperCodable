//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation
import SuperCodable
import XCTest

// MARK: - DecodeTests

final class DecodeTests: XCTestCase {
    // MARK: Internal

    func testKeyedWithKey() throws {
        let sut = try makeSUT(for: KeyedWithKey.self)
        XCTAssertEqual(sut.aID, "1")
    }

    func testKeyedWithoutKey() throws {
        let sut = try makeSUT(for: KeyedWithoutKey.self)
        XCTAssertEqual(sut.id, "1")
    }

    func testKeyedWithNestedKeyed() throws {
        let data =
            #"""
            {
                "object": {
                    "id": "1"
                }
            }
            """#.data(using: .utf8)!
        let sut = try JSONDecoder().decode(KeyedWitNestedKeyed.self, from: data)
        XCTAssertEqual(sut.aObject.aID, "1")
    }

    func testKeyedWithNestedCodable() throws {
        let data =
            #"""
            {
                "object": {
                    "bObject": {
                        "id": "1"
                    }
                }
            }
            """#.data(using: .utf8)!
        let sut = try JSONDecoder().decode(KeyWithNestedDeodable.self, from: data)
        XCTAssertEqual(sut.aObject.bObject.id, "1")
    }

    func testSuperDecodableWithNoneKeyedPropertyCannotSuccessfulDecode() throws {
        let sut = try makeSUT(for: SuperDecodableWithNoneKeyedProperty.self)
        XCTAssertNotEqual(sut.id, "1")
        XCTAssertTrue(sut.captured.isEmpty)
    }

    func testTransformWithKey() throws {
        let sut = try makeSUT(for: TransformWithKey.self)
        XCTAssertEqual(sut.aID, 1)
    }

    func testTransformWithKeyButTransformFailureShouldMakeDecodeFailure() throws {
        XCTAssertThrowsError(
            try makeSUT(for: TransformWithKey.self, customID: "abc")
        )
    }
    func testTransformWithoutKey() throws {
        let sut = try makeSUT(for: TransformWithoutKey.self)
        XCTAssertEqual(sut.id, 1)
    }

    func testTransformWithoutKeyButTransformFailureShouldMakeDecodeFailure() throws {
        XCTAssertThrowsError(
            try makeSUT(for: TransformWithoutKey.self, customID: "abc")
        )
    }

    // MARK: Private

    private func makeSUT<T: SuperDecodable>(
        for type: T.Type,
        customID: String = "1",
        file: StaticString = #filePath, line: UInt = #line
    ) throws -> T {
        let data =
            #"""
            {
                  "id": "\#(customID)"
            }
            """#.data(using: .utf8)!
        let sut = try JSONDecoder().decode(type.self, from: data)
        return sut
    }
}

// MARK: - KeyedWithKey

private struct KeyedWithKey: SuperDecodable {
    @Keyed("id")
    var aID: String
}

// MARK: - KeyedWithoutKey

private struct KeyedWithoutKey: SuperDecodable {
    @Keyed
    var id: String
}

// MARK: - KeyedWitNestedKeyed

private struct KeyedWitNestedKeyed: SuperDecodable {
    @Keyed("object")
    var aObject: KeyedWithKey
}

// MARK: - KeyWithNestedDeodable

private struct KeyWithNestedDeodable: SuperDecodable {
    struct AObject: Decodable {
        struct Bobject: Decodable {
            var id: String
        }

        var bObject: Bobject
    }

    @Keyed("object")
    var aObject: AObject
}

// MARK: - SuperDecodableWithNoneKeyedProperty

private struct SuperDecodableWithNoneKeyedProperty: SuperDecodable {
    var captured: [String] = []

    var id: String = "" {
        didSet {
            captured.append(id)
        }
    }
}

// MARK: - TransformWithKey

private struct TransformWithKey: SuperDecodable {
    @KeyedTransform("id", SCTransformOf<Int, String>(fromDecoder: {
        str in
        guard let transfromed = Int(str) else {
            throw NSError(domain: "transform Error, str:\(str) is not a Int", code: 0)
        }
        return transfromed
    }, toEncoder: {
        _ in
        fatalError("Not a test subject, should never happen")
    }))
    var aID: Int
}


private struct TransformWithoutKey: SuperDecodable {
    @KeyedTransform(SCTransformOf<Int, String>(fromDecoder: {
        str in
        guard let transfromed = Int(str) else {
            throw NSError(domain: "transform Error, str:\(str) is not a Int", code: 0)
        }
        return transfromed
    }, toEncoder: {
        _ in
        fatalError("Not a test subject, should never happen")
    }))
    var id: Int
}
