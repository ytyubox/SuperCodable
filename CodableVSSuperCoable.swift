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
        self.id = try container.decode(String.self, forKey: .id)
        self.aName = try container.decode(String.self, forKey: .aName)
        let gradeDecoded = try container.decode(Double.self, forKey: .grade)
        self.grade = Int(gradeDecoded)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case aName = "name"
        case grade = "grade"

    }

    var id: String
    var aName: String
    var grade: Int

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(aName, forKey: .aName)
        try container.encode(Double(grade), forKey: .grade)

    }
}

// MARK: - StudentWithSuperCodable

struct StudentWithSuperCodable: SuperCodable {
    var aID: String
    
    @Keyed("name")
    var aName: String
    
    @KeyedTransform(ToolBox.doubleTransform)
    var AGrade: Int
}

// MARK: - ToolBox

enum ToolBox {
    static let doubleTransform = SCTransformOf<Int, Double> {
        (double) -> Int in
        Int(double)
    } toEncoder: { (int) -> Double in
        Double(int) * 10
    }
}
