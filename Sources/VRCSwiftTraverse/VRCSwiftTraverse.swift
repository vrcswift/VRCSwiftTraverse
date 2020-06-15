//
//  Copyright 2020 The VRC Authors. All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE.md file.
//

//
//  MARK: Imports.
//
import Foundation
import SwiftyJSON

//
//  MARK: Public defines.
//

///
///  Traverse error object.
///
public struct VRCTraverseError: Swift.Error {
    public enum VRCTraverseErrorKind {
        case parameterError
        case typeError
        case keyNotFindError
        case invalidTypeError
        case outOfRangeError
    }
        
    public let message: String
    public let kind: VRCTraverseErrorKind
    public let path: String
}

extension VRCTraverseError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

///
///  The traverse type.
///
public enum VRCTraverseType {
    case numeric
    case boolean
    case string
    case array
    case dictionary
    case null
}

//
//  MARK: Public classes.
//

///
///  Traverse of JSON object.
///
public class VRCTraverse {
    //
    //  MARK: VRCTraverse members.
    //
    
    //  The inner JSON object.
    private let m_Inner: JSON
    
    //  The path.
    private let m_Path: String
    
    //
    //  MARK: VRCTraverse constructor.
    //
    
    ///
    ///  Constructor with JSON data.
    ///
    ///  - Throws: Raised if JSON data is invalid.
    ///
    ///  - Parameters:
    ///    - data: The data.
    ///    - opt: The JSON serialization reading options. Default is '[]'.
    ///    - path: The path.
    ///
    public init(data: Data,
        options: JSONSerialization.ReadingOptions = [],
        path: String = "/") throws {
        //  Build JSON object.
        m_Inner = try JSON(data: data, options: options)
        
        //  Initialize path.
        m_Path = path
    }
    
    ///
    ///  Constructor with a JSON object.
    ///
    ///  - Throws: Raised if JSON object is invalid.
    ///
    ///  - Parameters:
    ///    - object: The JSON object.
    ///    - path: The path.
    ///
    public init(_ object: Any, _ path: String = "/") throws {
        m_Inner = JSON(object)
        
        //  Check if JSON is invalid.
        if m_Inner.type == .null {
            throw VRCTraverseError(
                message: "The JSON is invalid.",
                kind: .parameterError, path: path)
        }
        
        //  Initialize path.
        m_Path = path
    }
    
    ///
    ///  Constructor with JSON string.
    ///
    ///  - Throws: Raised if JSON string is invalid.
    ///
    ///  - Parameters:
    ///    - jsonString: The JSON string.
    ///    - path: The path.
    ///
    public init(parseJSON jsonString: String, path: String = "/") throws {
        m_Inner = JSON(parseJSON: jsonString)
        
        //  Check if JSON is invalid.
        if m_Inner.type == .null {
            throw VRCTraverseError(
                message: "The JSON is invalid.",
                kind: .parameterError, path: path)
        }
        
        //  Initialize path.
        m_Path = path
    }
    
    ///
    /// Raised with inner JSON object
    ///
    /// - Parameters:
    ///   - inner: The inner object.
    ///   - path: The path.
    ///
    private init(inner: JSON, path: String = "/") {
        //  Initialize.
        m_Inner = inner
        m_Path = path
    }
    
    //
    //  MARK: VRCTraverse private methods.
    //

    ///
    /// Get the sub path with name string.
    ///
    /// - Parameter name: The sub name.
    ///
    /// - Returns: The sub path.
    ///
    private func getSubPath(name: String) -> String {
        if m_Path.count == 0 || m_Path.hasSuffix("/") {
            return m_Path + name
        } else {
            return m_Path + "/" + name
        }
    }
    
    ///
    ///  Get the representation of specified object.
    ///
    ///  - Parameter obj: The object.
    ///
    ///  - Returns: The representation string.
    ///
    private func getObjectRepresentation(_ obj: Any) -> String {
        return "\(obj)"
    }
    
    ///
    ///  Get the sub path with offset of array.
    ///
    ///  - Parameter offset: The offset of array.
    ///
    ///  - Returns: The sub path.
    ///
    private func getSubPath(offset: Int) -> String {
        if m_Path.count == 0 || m_Path.hasSuffix("/") {
            return m_Path + String.init(format: "[%d]", offset)
        } else {
            return m_Path + "/" + String.init(format: "[%d]", offset)
        }
    }
    
    ///
    /// Assert with type error.
    ///
    /// - Throws: Raised if expression is 'false'.
    ///
    /// - Parameter isEqual: The expression.
    ///
    private func assertForTypeInvalid(isEqual: Bool) throws {
        if !isEqual {
            throw VRCTraverseError(
                message: "Invalid JSON object type.",
                kind: .typeError, path: m_Path)
        }
    }
    
    //
    //  MARK: VRCTraverse public methods.
    //

    ///
    /// Check whether inner object matches this type.
    ///
    /// - Throws: Raised if inner object does not match this type.
    ///
    /// - Parameter type: The type.
    ///
    /// - Returns: Self.
    ///
    public func typeOf(_ type: VRCTraverseType) throws -> VRCTraverse {
        if m_Inner.type == .null {
            return self
        }
        
        //  Check inner type.
        switch type {
        case .numeric:
            try assertForTypeInvalid(isEqual: m_Inner.type == .number)
        case .string:
            try assertForTypeInvalid(isEqual: m_Inner.type == .string)
        case .boolean:
            try assertForTypeInvalid(isEqual: m_Inner.type == .bool)
        case .array:
            try assertForTypeInvalid(isEqual: m_Inner.type == .array)
        case .dictionary:
            try assertForTypeInvalid(isEqual: m_Inner.type == .dictionary)
        case .null:
            try assertForTypeInvalid(isEqual: m_Inner.type == .null)
        }
        
        return self
    }

    ///
    ///  Check whether inner object is a numeric.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: Self.
    ///
    public func numeric() throws -> VRCTraverse {
        //  Check inner type.
        _ = try self.typeOf(.numeric)
        
        return self
    }
    
    ///
    ///  Check whether inner object is a integer.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: Self.
    ///
    public func integer() throws -> VRCTraverse {
        if m_Inner.type == .null {
            return self
        }
        
        //  Check inner type.
        if m_Inner.type == .number &&
            IsNSNumberInteger(val: m_Inner.numberValue) {
            return self
        }
        
        throw VRCTraverseError(
            message: "Value shoule be a integer",
            kind: .typeError, path: m_Path)
    }

    ///
    ///  Check whether inner object is a boolean.
    ///
    ///  - Throws: Raised if inner object is not a boolean.
    ///
    ///  - Returns: Self.
    ///
    public func boolean() throws -> VRCTraverse {
        //  Check type.
        _ = try self.typeOf(.boolean)
        
        return self
    }
    
    ///
    ///  Check whether inner object is a string.
    ///
    ///  - Throws: Raised if inner object is not a string.
    ///
    ///  - Returns: Self.
    ///
    public func string() throws -> VRCTraverse {
        //  Check type.
        _ = try self.typeOf(.string)
        
        return self
    }
    
    ///
    ///  Check whether inner object is a array.
    ///
    ///  - Throws: Raised if inner object is not a array.
    ///
    ///  - Returns: Self.
    ///
    public func array() throws -> VRCTraverse {
        //  Check type.
        _ = try self.typeOf(.array)
        
        return self
    }
    
    ///
    ///  Check whether inner object is a directory.
    ///
    ///  - Throws: Raised if inner object is not a directory.
    ///
    ///  - Returns: Self.
    ///
    public func directory() throws -> VRCTraverse {
        //  Check type.
        _ = try self.typeOf(.dictionary)
        
        return self
    }

    ///
    ///  Get sub item of directory.
    ///
    ///  - Throws: Raised in the following situations:
    ///
    ///             - The inner object is 'NULL'.
    ///             - The inner object is no a directory.
    ///             - Raised if sub path is not existed.
    ///
    ///  - Parameter name: The key of sub item.
    ///
    ///  - Returns: Traverse object of sub item
    ///
    public func sub(_ name: String) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().directory()
        
        //  Sub path.
        let subPath = self.getSubPath(name: name)
        
        //  Get sub item.
        let subInner = m_Inner[name]
        
        //  Check sub item's type.
        if subInner.error != nil {
            throw VRCTraverseError(
                message: "Sub path is not existed.",
                kind: .keyNotFindError, path: subPath)
        }
        
        return VRCTraverse(inner: subInner, path: subPath)
    }

    ///
    ///  Get sub item of directory, which can be non-existed.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is 'NULL'.
    ///             - The inner object is not a directory.
    ///
    ///  - Parameters:
    ///    - name: The name(key) of directory.
    ///    - defaultValue: The default value if sub item doesn't exist.
    ///
    ///  - Returns: Traverse object of sub item.
    ///
    public func optionalSub(
        _ name: String, defaultValue:Any? = nil) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().directory()

        //  Sub path.
        let subPath = self.getSubPath(name: name)
        
        //  Get sub item.
        let subInner = m_Inner[name]
        
        //  Check sub item's type.
        if subInner.error != nil {
            //  Get sub item of default value.
            guard let subInner = JSON(rawValue: defaultValue ?? NSNull()) else {
                throw VRCTraverseError(
                    message: "Cannot recognize the type of default value.",
                    kind: .parameterError, path: subPath)
            }
            return VRCTraverse(inner: subInner, path: subPath)
        }
        
        return VRCTraverse(inner: subInner, path: subPath)
    }
    
    ///
    ///  Check whether inner object is not a 'NULL'.
    ///
    ///  - Throws: Raised if inner object is a 'NULL'.
    ///
    ///  - Returns: Self.
    ///
    public func notNull() throws -> VRCTraverse {
        if m_Inner.type == .null {
            throw VRCTraverseError(
                message: "Value should not be null.",
                kind: .typeError, path: m_Path)
        }
        
        return self
    }
    
    ///
    ///  Set minimum value threshold for inner object.
    ///
    ///  - Note:
    ///         What is expected: inner >= threshold.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object and threshold are of different types.
    ///             - 'inner' < 'threshold'.
    ///
    ///  - Parameter threshold: The threshold.
    ///
    ///  - Returns: Self.
    ///
    public func min(_ threshold: Any) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type != .null {
            //  Threshold inner.
            let tInner = JSON(threshold)
            
            if tInner.type != m_Inner.type {
                throw VRCTraverseError(
                    message: "Inconsistent types.",
                    kind: .parameterError, path: m_Path)
            }
            
            if m_Inner < tInner {
                throw VRCTraverseError(
                    message: "Too small value. (require=" +
                    "'>=', threshold='\(threshold)')",
                    kind: .outOfRangeError, path: m_Path)
            }
        }
        
        return self
    }
    
    ///
    ///  Set exclusive minimum value threshold for inner object.
    ///
    ///  - Note:
    ///         What is expected: inner > threshold.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object and threshold are of different types.
    ///             - 'inner' <= 'threshold'.
    ///
    ///  - Parameter threshold: The threshold.
    ///
    ///  - Returns: Self.
    ///
    public func minExclusive(_ threshold: Any) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type != .null {
            //  Threshold inner.
            let tInner = JSON(threshold)
            
            if tInner.type != m_Inner.type {
                throw VRCTraverseError(
                    message: "Inconsistent types.",
                    kind: .parameterError, path: m_Path)
            }
            
            if m_Inner <= tInner {
                throw VRCTraverseError(
                    message: "Too small value. (require=" +
                    "'>', threshold='\(threshold)')",
                    kind: .outOfRangeError, path: m_Path)
            }
        }
        
        return self
    }
    
    ///
    ///  Set maximum value threshold for inner object.
    ///
    ///  - Note:
    ///         What is expected: inner <= threshold.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object and threshold are of different types.
    ///             - 'inner' > 'threshold'.
    ///
    ///  - Parameter threshold: The threshold.
    ///
    ///  - Returns: Self.
    ///
    public func max(_ threshold: Any) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type != .null {
            //  Threshold inner.
            let tInner = JSON(threshold)
            
            if tInner.type != m_Inner.type {
                throw VRCTraverseError(
                    message: "Inconsistent types.",
                    kind: .parameterError, path: m_Path)
            }
            
            if m_Inner > tInner {
                throw VRCTraverseError(
                    message: "Too large value. (require=" +
                    "'<=', threshold='\(threshold)')",
                    kind: .outOfRangeError, path: m_Path)
            }
        }
        
        return self
    }
    
    ///
    ///  Set exclusive maximum value threshold for inner object.
    ///
    ///  - Note:
    ///         What is expected: inner < threshold.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object and threshold are of different types.
    ///             - 'inner' >= 'threshold'.
    ///
    ///  - Parameter threshold: The threshold.
    ///
    ///  - Returns: Self.
    ///
    public func maxExclusive(_ threshold: Any) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type != .null {
            //  Threshold inner.
            let tInner = JSON(threshold)
            
            if tInner.type != m_Inner.type {
                throw VRCTraverseError(
                    message: "Inconsistent types.",
                    kind: .parameterError, path: m_Path)
            }
            
            if m_Inner >= tInner {
                throw VRCTraverseError(
                    message: "Too large value. (require=" +
                    "'<', threshold='\(threshold)')",
                    kind: .outOfRangeError, path: m_Path)
            }
        }
        
        return self
    }
    
    ///
    ///  Select an item from specific dictionary (use inner object as the key).
    ///
    ///  - Throws: Raised in the following situations:
    ///
    ///             - The inner object is 'NULL'.
    ///             - The key doesn't exist.
    ///
    ///  - Parameter from: The dictionary.
    ///
    ///  - Returns: Traverse object of selected item.
    ///
    public func selectFromDictionary<T1, T2>(
        from: [T1: T2]) throws -> VRCTraverse {
        
        //  Get key.
        let key: T1 = try self.notNull().inner()
        
        //  Check key existence.
        if let val = from[key] {
            return try VRCTraverse(
                val, getSubPath(name: getObjectRepresentation(key)))
        }
        
        throw VRCTraverseError(
            message: "\"key\" does not existed.",
            kind: .keyNotFindError,
            path: m_Path)
    }
    
    ///
    ///  Select an optional item from specific dictionary (inner object as the key).
    ///
    ///  - Throws: Raised if the inner object is 'NULL'.
    ///
    ///  - Parameters:
    ///    - from: The dictionary.
    ///    - defaultValue: The default value when the key doesn't exist.
    ///
    ///  - Returns: Traverse object of selected item.
    ///
    public func selectFromDictionaryOptional<T1, T2>(
        from: [T1: T2],
        defaultValue: T2) throws -> VRCTraverse {
        
        do {
            return try selectFromDictionary(from: from)
        } catch let error as VRCTraverseError {
            if error.kind == .keyNotFindError {
                return try VRCTraverse(
                    defaultValue,
                    getSubPath(name:
                        getObjectRepresentation(m_Inner.rawValue))
                )
            }
            throw error
        } catch let error {
            throw error
        }
    }

    ///
    ///  Get item of array.
    ///
    ///  - Throws: Raised in the following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not an array.
    ///             - The offset is out of range.
    ///
    ///  - Parameter offset: The offset of item within array.
    ///
    ///  - Returns: Traverse object of item.
    ///
    public func arrayGetItem(_ offset: Int) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().array()
        
        //  Check the offset.
        if offset < 0 || offset >= m_Inner.arrayValue.count {
            throw VRCTraverseError(
                message: "Offset is out of range.",
                kind: .outOfRangeError, path: self.getSubPath(offset: offset))
        }
        
        //  Sub inner.
        let newInner = m_Inner[offset]
        return VRCTraverse(
            inner: newInner, path: self.getSubPath(offset: offset))
    }
    
    ///
    ///  Iterating through array.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not an array.
    ///
    ///  - Parameter handler: The callback.
    ///
    ///  - Returns: Self.
    ///
    public func arrayForEach(
        _ handler: (VRCTraverse) throws -> Void) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().array()
        
        //  Scan all items.
        for i in 0..<m_Inner.arrayValue.count {
            let newInner = m_Inner[i]
            try handler(VRCTraverse(
                inner: newInner, path: self.getSubPath(offset: i)))
        }
        
        return self
    }
    
    ///
    ///  Get inner object as a signed 8-bit integer.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The signed 8-bit integer.
    ///
    public func innerAsSInt8() throws -> Int8 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.int8Value
    }
    
    ///
    ///  Get inner object as an optional signed int8.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional signed int8 value.
    ///
    public func innerAsOptionalSInt8() throws -> Int8? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.int8
    }
    
    ///
    ///  Get inner object as  an unsigned int8.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The unsigned int8 value.
    ///
    public func innerAsUInt8() throws -> UInt8 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.uInt8Value
    }
    
    ///
    ///  Get inner object as  an optional unsigned int8.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional unsigned int8 value.
    ///
    public func innerAsOptionalUInt8() throws -> UInt8? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.uInt8
    }
    
    ///
    ///  Get inner object as a signed int16.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The signed int16 value.
    ///
    public func innerAsSInt16() throws -> Int16 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.int16Value
    }
    
    ///
    ///  Get inner object as an optional signed int16.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional signed int16 value.
    ///
    public func innerAsOptionalSInt16() throws -> Int16? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.int16
    }
    
    ///
    ///  Get inner object as an unsigned int16.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The unsigned int16 value.
    ///
    public func innerAsUInt16() throws -> UInt16 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.uInt16Value
    }
    
    ///
    ///  Get inner object as an optional unsigned int16.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional unsigned int16 value.
    ///
    public func innerAsOptionalUInt16() throws -> UInt16? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.uInt16
    }
    
    ///
    ///  Get inner object as a signed int32.
    ///
    ///  - Throws: Raised in the situations:
    ///
    ///             - The inner object is a 'NULL'
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The signed int32 value.
    ///
    public func innerAsSInt32() throws -> Int32 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.int32Value
    }
    
    ///
    ///  Get inner object as an optional signed int32.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional signed int32 value.
    ///
    public func innerAsOptionalSInt32() throws -> Int32? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.int32
    }
    
    ///
    ///  Get inner object as an unsigned int32.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The unsigned int32 value.
    ///
    public func innerAsUInt32() throws -> UInt32 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.uInt32Value
    }
    
    ///
    ///  Get inner object as an optional unsigned int32.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional unsigned int32 value.
    ///
    public func innerAsOptionalUInt32() throws -> UInt32? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.uInt32
    }
    
    ///
    ///  Get inner object as a signed int64.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The signed int64 value.
    ///
    public func innerAsSInt64() throws -> Int64 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.int64Value
    }
    
    ///
    ///  Get inner object as an optional signed int64.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional signed int64 value.
    ///
    public func innerAsOptionalSInt64() throws -> Int64? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.int64
    }
    
    ///
    ///  Get inner object as an unsigned int64.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The unsigned int64 value.
    ///
    public func innerAsUInt64() throws -> UInt64 {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.uInt64Value
    }
    
    ///
    ///  Get inner object as an optional unsigned int64.
    ///
    ///  - Throws; Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional unsigned int64 value.
    ///
    public func innerAsOptionalUInt64() throws -> UInt64? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.uInt64
    }
    
    ///
    ///  Get inner object as a signed integer.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The integer value.
    ///
    public func innerAsSInt() throws -> Int {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.intValue
    }
    
    ///
    ///  Get inner object as an optional signed integer.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The integer value.
    ///
    public func innerAsOptionalSInt() throws -> Int? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.int
    }
    
    ///
    ///  Get inner object as an unsigned integer.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The unsigned integer value.
    ///
    public func innerAsUInt() throws -> UInt {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.uIntValue
    }
    
    ///
    ///  Get inner object as an optional unsigned integer.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional unsigned integer value.
    ///
    public func innerAsOptionalUInt() throws -> UInt? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.uInt
    }
    
    ///
    ///  Get inner object as a double.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The double value.
    ///
    public func innerAsDouble() throws -> Double {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.doubleValue
    }
    
    ///
    ///  Get inner object as an optional double.
    ///
    ///  - Throws: Raised if inner object is not a numeric.
    ///
    ///  - Returns: The optional double value.
    ///
    public func innerAsOptionalDouble() throws -> Double? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.double
    }
    
    ///
    ///  Get inner object as a float.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a numeric.
    ///
    ///  - Returns: The float value.
    ///
    public func innerAsFloat() throws -> Float {
        //  Check type.
        _ = try self.notNull().numeric()
        
        return m_Inner.floatValue
    }
    
    ///
    ///  Get inner object as  anoptional float.
    ///
    ///  - Throws: Raised if inner object is not a numeric
    ///
    ///  - Returns: The optional float value.
    ///
    public func innerAsOptionalFloat() throws -> Float? {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.float
    }
    
    ///
    ///  Get inner object as a string.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a string.
    ///
    ///  - Returns: The string value.
    ///
    public func innerAsString() throws -> String {
        //  Check type.
        _ = try self.notNull().string()
        
        return m_Inner.stringValue
    }
    
    ///
    ///  Get inner object as an optional string.
    ///
    ///  - Throws: Raised if inner object is not a string.
    ///
    ///  - Returns: The optional string value.
    ///
    public func innerAsOptionalString() throws -> String? {
        //  Check type.
        _ = try self.string()
        
        return m_Inner.string
    }
    
    ///
    ///  Get inner object as a boolean.
    ///
    ///  - Throws: Raised in following situations:
    ///
    ///             - The inner object is a 'NULL'.
    ///             - The inner object is not a boolean.
    ///
    ///  - Returns: The boolean value.
    ///
    public func innerAsBoolean() throws -> Bool {
        //  Check type.
        _ = try self.notNull().boolean()
        
        return m_Inner.boolValue
    }

    ///
    ///  Get inner object as an optional boolean.
    ///
    ///  - Throws: Raised if inner object is not a boolean.
    ///
    ///  - Returns: The optional boolean value.
    ///
    public func innerAsOptionalBoolean() throws -> Bool? {
        //  Check type.
        _ = try self.boolean()
        
        return m_Inner.bool
    }

    ///
    ///  Get inner object.
    ///
    ///  - Throws: Raised iin following situations:
    ///
    ///             - It's not supported for the type.
    ///             - Cannot get value as target type.
    ///
    ///  - Returns: The inner object.
    ///
    public func inner<T>() throws -> T {
        if type(of: T.self) == Int8.Type.self {
            return try self.innerAsSInt8() as! T
        } else if type(of: T.self) == Int8?.Type.self {
            return try self.innerAsOptionalSInt8() as! T
        } else if type(of: T.self) == UInt8.Type.self {
            return try self.innerAsUInt8() as! T
        } else if type(of: T.self) == UInt8?.Type.self {
            return try self.innerAsOptionalUInt8() as! T
        } else if type(of: T.self) == Int16.Type.self {
            return try self.innerAsSInt16() as! T
        } else if type(of: T.self) == Int16?.Type.self {
            return try self.innerAsOptionalSInt16() as! T
        } else if type(of: T.self) == UInt16.Type.self {
            return try self.innerAsUInt16() as! T
        } else if type(of: T.self) == UInt16?.Type.self {
            return try self.innerAsOptionalUInt16() as! T
        } else if type(of: T.self) == Int32.Type.self {
            return try self.innerAsSInt32() as! T
        } else if type(of: T.self) == Int32?.Type.self {
            return try self.innerAsOptionalSInt32() as! T
        } else if type(of: T.self) == UInt32.Type.self {
            return try self.innerAsUInt32() as! T
        } else if type(of: T.self) == UInt32?.Type.self {
            return try self.innerAsOptionalUInt32() as! T
        } else if type(of: T.self) == Int64.Type.self {
            return try self.innerAsSInt64() as! T
        } else if type(of: T.self) == Int64?.Type.self {
            return try self.innerAsOptionalSInt64() as! T
        } else if type(of: T.self) == UInt64.Type.self {
            return try self.innerAsUInt64() as! T
        } else if type(of: T.self) == UInt64?.Type.self {
            return try self.innerAsOptionalUInt64() as! T
        } else if type(of: T.self) == String.Type.self {
            return try self.innerAsString() as! T
        } else if type(of: T.self) == String?.Type.self {
            return try self.innerAsOptionalString() as! T
        } else if type(of: T.self) == Bool.Type.self {
            return try self.innerAsBoolean() as! T
        } else if type(of: T.self) == Bool?.Type.self {
            return try self.innerAsOptionalBoolean() as! T
        } else {
            throw VRCTraverseError(message: "Cannot recognize the type.",
                kind: .invalidTypeError, path: m_Path)
        }
    }
}
