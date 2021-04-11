//
/*
 *		Created by 游宗諭 in 2021/4/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - StudentWithCodable

struct StudentWithCodable: Codable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.aID = try container.decode(String.self, forKey: .aID)
        self.aName = try container.decode(String.self, forKey: .aName)
        let gradeDecoded = try container.decode(Double.self, forKey: .aGrade)
        self.AGrede = Int(gradeDecoded)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case aName = "name"
        case aGrade = "grade"
        case aID = "id"
    }

    var aID: String
    var aName: String
    var AGrede: Int

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aID, forKey: .aID)
        try container.encode(Double(AGrede), forKey: .aGrade)
        try container.encode(aName, forKey: .aName)
    }
}

// MARK: - StudentWithSuperCodable

struct StudentWithSuperCodable: SuperCodable {
    @Keyed("id")
    var aID: String
    @Keyed("name") // --> key
    var aName: String
    @KeyedTransform("grade", ToolBox.doubleTransform)
    var AGrede: Int
}

// MARK: - ToolBox

enum ToolBox {
    static let doubleTransform = FATransformOf<Int, Double> {
        (double) -> Int in
        Int(double)
    } toEncoder: { (int) -> Double in
        Double(int) * 10
    }
}
