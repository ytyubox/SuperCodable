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
    // MARK: Lifecycle

    init(id: String) {
        self.id = id
    }

    // MARK: Internal

    @Keyed
    var id: String
}
