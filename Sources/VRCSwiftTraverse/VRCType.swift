//
//  File.swift
//  
//
//  Created by varme on 2020/3/28.
//

import Foundation

///
///  Check whether if NSNumber value is a integer.
///
///  - Parameter val: The value.
///
func isNSNumberInteger(val: NSNumber) -> Bool {
    switch CFNumberGetType(val) {
    case .sInt8Type:
        return true
    case .sInt16Type:
        return true
    case .sInt32Type:
        return true
    case .sInt64Type:
        return true
    case .float32Type:
        return false
    case .float64Type:
        return false
    case .charType:
        return false
    case .shortType:
        return true
    case .intType:
        return true
    case .longType:
        return true
    case .longLongType:
        return true
    case .floatType:
        return false
    case .doubleType:
        return false
    case .cfIndexType:
        return true
    case .nsIntegerType:
        return true
    case .cgFloatType:
        return false
    default:
        return false
    }
}
