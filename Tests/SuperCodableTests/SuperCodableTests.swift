import SuperCodable
import XCTest

let doubleTransform = SCTransformOf<Int, Double> {
    (double) -> Int in
    Int(double)
} toEncoder: { (int) -> Double in
    Double(int) * 10
}

// MARK: - Student

struct Student: SuperCodable {
    @Keyed
    var id: String
    @Keyed("name")
    var aName: String
    @KeyedTransform("grade", doubleTransform)
    var AGrade: Int
}

// MARK: - SuperCodableTests

final class SuperCodableTests: XCTestCase {
    func test() throws {
        let data =
            #"""
            [
               {
                  "id": "1",
                  "name": "Josh",
                  "grade": 3.18
               },
               {
                  "id": "2",
                  "name": "Marc",
                  "grade": 2.25
               },
               {
                  "id": "3",
                  "name": "Judy",
                  "grade": 4.00
               }
            ]
            """#.data(using: .utf8)!
        let sut = try! JSONDecoder().decode([Student].self, from: data)
        XCTAssertEqual(sut.count,
                       3)
        XCTAssertEqual(
            sut.map(\.AGrade),
            [3, 2, 4])
        let encoded = try JSONEncoder().encode(sut)
        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        XCTAssertEqual("""
        [{"id":"1","name":"Josh","grade":30},{"id":"2","name":"Marc","grade":20},{"id":"3","name":"Judy","grade":40}]
        """, encodedString)
    }
}
