//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import SuperCodable
import XCTest

// MARK: - EncodableTests

final class EncodableTests: XCTestCase {
    func testKeyedWithKey() throws {
        let sut = KeyedWithKey(id: "1")
        XCTAssertEqual(sut.aID, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":"1"}
            """#)
    }

    func testKeyedWithoutKey() throws {
        let sut = KeyedWithoutKey(id: "1")
        XCTAssertEqual(sut.id, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":"1"}
            """#)
    }

    func testKeyedWithNestedEncodable() throws {
        let sut = KeyWithNestedEncodable()
        sut.object = KeyWithNestedEncodable.AObject(bObject: KeyWithNestedEncodable.AObject.Bobject(id: "1"))
        XCTAssertEqual(sut.object.bObject.id, "1")
        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"Aobject":{"bObject":{"id":"1"}}}
            """#)
    }
}

// MARK: - KeyedWithKey

private struct KeyedWithKey: SuperEncodable {
    // MARK: Lifecycle

    init(id: String) {
        self.aID = id
    }

    // MARK: Internal

    @Keyed("id")
    var aID: String
}

// MARK: - KeyedWithoutKey

private struct KeyedWithoutKey: SuperEncodable {
    init(id: String) {
        self._id = .init("")
        self.id = id
    }
    @Keyed
    var id: String
}

// MARK: - KeyWithNestedEncodable

private struct KeyWithNestedEncodable: SuperEncodable {
    struct AObject: Encodable {
        struct Bobject: Encodable {
            var id: String
        }

        var bObject: Bobject
    }

    @Keyed("Aobject")
    var object: AObject
}
