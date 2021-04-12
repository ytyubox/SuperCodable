//
/* 
 *		Created by 游宗諭 in 2021/4/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation
enum Lazy<T> {
    case yet
    case already(T)
    case none
}
