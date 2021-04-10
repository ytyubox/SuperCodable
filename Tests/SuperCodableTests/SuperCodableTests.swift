import XCTest
@testable import SuperCodable

final class SuperCodableTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SuperCodable().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
