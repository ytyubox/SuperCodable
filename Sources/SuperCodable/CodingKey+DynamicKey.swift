//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

// MARK: - DynamicCodingKeys

public struct DynamicKey: CodingKey {
    // MARK: Lifecycle

    init(key: String) {
        self.stringValue = key
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    // MARK: Public

    public var stringValue: String
    public var intValue: Int?
}
