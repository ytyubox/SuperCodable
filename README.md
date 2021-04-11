# SuperCodable

Inspired by: https://medium.com/trueid-developers/combined-propertywrapper-with-codable-swift-368dc4aa2703


> From Foundation

```swift
struct AStudent: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.aID = try container.decode(String.self, forKey: .aID)
        self.aName = try container.decode(String.self, forKey: .aName)
        let gradeDecoded = try container.decode(Double.self, forKey: .aGrade)
        self.AGrede = Int(gradeDecoded)
    }

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
```


> To SuperCodable

```swift
struct Student: SuperCodable {
    @Keyed("id")
    var aID: String
    
    @Keyed("name") 
    var aName: String
    
    @KeyedTransform("grade", doubleTransform)
    var AGrede: Int
}

let doubleTransform = FATransformOf<Int, Double> {
    (double) -> Int in
    Int(double)
} toEncoder: { (int) -> Double in
    Double(int)
}
```


## Known side effect 

- SuperDecoable must construct from nothing `(init()`)
- `@Keyed var id:Int` will do O(n) calculation on underlaying wrapper `_id` into key `id`.
