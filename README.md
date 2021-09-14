# SuperCodable


##  From Foundation

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


## To SuperCodable

```swift
struct Student: SuperCodable {
    @Keyed
    var id: String
    
    @Keyed("name") 
    var aName: String
    
    @KeyedTransform("grade", doubleTransform)
    var AGrade: Int
}

let doubleTransform = SCTransformOf<Int, Double> {
    (double) -> Int in
    Int(double)
} toEncoder: { (int) -> Double in
    Double(int)
}
```

## Even random backend type

```swift
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
            sut.map(\._id),
            [0, 1, 0, 1])
```

Can be found in `Tests/SuperCodableTests/AnyValueDecode.swift`

## Feature

- Working with Nested `Foundation.Codable` property

## Known side effect 

- SuperDecoable must construct from nothing `init()`
- `@Keyed var id:Int` will do **O(n) calculation** on underlaying wrapper `_VARIABLE_NAME` into key `VARIABLE_NAME`. **Be ware of variable name takes too long**


## Known Disability

- Every property in a SuperCodable should a `DecodableKey` / `EncodableKey`, otherwise the property(which should be `Codable`) will **simply ignored** during the Codable process.
> Why:
>> Basically Mirror can't mutating the object value during the  `init(from decoder:) throws`, since we create the object from `self.init()`


## Other notes

- Inspired by: https://medium.com/trueid-developers/combined-propertywrapper-with-codable-swift-368dc4aa2703

- Try to merge `@KeyedTransform` into `@Keyed`, but it required `@Keyed var id: String` to be `@Keyed() var id: String`, with extra `()` 🧐

- Swift should auto generate `STRUCT.init(....)` for you, **but** if you using `@Keyed var id: String` without default value, it will generate `init(id: Keyed<String>)`, by giving default value `@Keyed var id: String = ""` should solve this problem. 

## Know Issues

- `@Keyed var id:String?` will cause fatalError on force unwrapping `Keyed.value?`, you can using `@OptionalKeyed` to make it works.
- `OptionalKeyed` may / may not a good name, I am thinking of make the easy to change, maybe `KeyedOptional` is EASY change? 🤔
