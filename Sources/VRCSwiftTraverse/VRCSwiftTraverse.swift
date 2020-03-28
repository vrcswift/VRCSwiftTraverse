//  MARK: Imports.
import Foundation
import SwiftyJSON

//  MARK: Error.

///
///  Traverse error object.
///
public struct VRCTraverseError: Swift.Error {
    public enum VRCTraverseErrorKind {
        case parameterError
        case typeError
        case keyNotFindError
        case unknownTypeError
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
    case numericType
    case booleanType
    case stringType
    case arrayType
    case dictionaryType
    case nullType
}

//  MARK: Public classes.

///
///  Traverse of JSON object.
///
public class VRCTraverse {
    //  MARK: Members.
    
    //  The inner JSON object.
    let m_Inner: JSON
    
    //  The path.
    let m_Path: String
    
    //  MARK: VRCTraverse constructor.
    
    ///
    ///  Constructor with JSON data.
    ///
    ///  - Throws: Raised if JSON data is invalid.
    ///
    ///  - Parameters:
    ///    - data: The data.
    ///    - path: The path.
    ///    - opt: The JSON serialization reading options. Default is '[]'.
    ///
    init(data: Data, path: String = "/",
        options opt: JSONSerialization.ReadingOptions = []) throws {
        //  Build JSON object.
        m_Inner = try JSON(data: data, options: opt)
        
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
    init(_ object: Any, _ path: String = "/") throws {
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
    init(parseJSON jsonString: String, path: String = "/") throws {
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
    fileprivate init(inner: JSON, path: String = "/") {
        //  Initialize.
        m_Inner = inner
        m_Path = path
    }
    
    //  MARK: VRCTraverse private methods.

    ///
    /// Get the sub path with name string.
    ///
    /// - Parameter name: The sub name.
    ///
    /// - Returns: The sub path.
    ///
    fileprivate func getSubPath(name: String) -> String {
        if m_Path.count == 0 || m_Path.hasSuffix("/") {
            return m_Path + name
        } else {
            return m_Path + "/" + name
        }
    }
    
    ///
    ///  Get the sub path with offset of array.
    ///
    ///  - Parameter offset: The offset of array.
    ///
    ///  - Returns: The sub path.
    ///
    fileprivate func getSubPath(offset: Int) -> String {
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
    fileprivate func assertForTypeInvalid(isEqual: Bool) throws {
        if !isEqual {
            throw VRCTraverseError(
                message: "Invalid JSON object type.",
                kind: .typeError, path: m_Path)
        }
    }
    
    //  MARK: VRCTraverse public methods.

    ///
    /// Check the type of inner object
    ///
    /// - Throws: Raised if inner object is not type.
    ///
    /// - Parameter type: The type.
    ///
    /// - Returns: Self.
    ///
    public func typeOf(type: VRCTraverseType) throws -> VRCTraverse {
        if m_Inner.type == .null {
            return self
        }
        
        //  Check inner type.
        switch type {
        case .numericType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .number)
        case .stringType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .string)
        case .booleanType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .bool)
        case .arrayType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .array)
        case .dictionaryType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .dictionary)
        case .nullType:
            try assertForTypeInvalid(isEqual: m_Inner.type == .null)
        }
        
        return self
    }

    ///
    ///  Assume that inner object is numeric.
    ///
    ///  - Throws: Raised if inner object is not numeric.
    ///
    ///  - Returns: Self.
    ///
    public func numeric() throws -> VRCTraverse {
        //  Check inner type.
        if m_Inner.type == .null || m_Inner.type == .number {
            return self
        }
        
        throw VRCTraverseError(
            message: "Value should be a number",
            kind: .typeError, path: m_Path)
    }
    
    ///
    ///  Assume that inner object is integer.
    ///
    ///  - Throws: Raised if inner object is not integer.
    ///
    ///  - Returns: Self.
    ///
    public func integer() throws -> VRCTraverse {
        if m_Inner.type == .null {
            return self
        }
        
        //  Check inner type.
        if m_Inner.type == .number &&
            isNSNumberInteger(val: m_Inner.numberValue) {
            return self
        }
        
        throw VRCTraverseError(
            message: "Value shoule be a integer",
            kind: .typeError, path: m_Path)
    }

    ///
    ///  Assume that inner object is boolean.
    ///
    ///  - Throws: Raised if inner object is not boolean.
    ///
    ///  - Returns: Self.
    ///
    public func boolean() throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type == .null || m_Inner.type == .bool {
            return self
        }
        
        throw VRCTraverseError(
            message: "Value should be a boolean",
            kind: .typeError, path: m_Path)
    }
    
    ///
    ///  Assume that inner object is a string.
    ///
    ///  - Throws: Raised if inner object is not string.
    ///
    ///  - Returns: Self.
    ///
    public func string() throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type == .null || m_Inner.type == .string {
            return self
        }
        
        throw VRCTraverseError(
            message: "Value should be a string.",
            kind: .typeError, path: m_Path)
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
    public func sub(name: String) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type != .dictionary {
            throw VRCTraverseError(
                message: "Value should be a dictionary.", kind: .typeError, path: m_Path)
        }
        
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
        name: String, defaultValue:Any? = nil) throws -> VRCTraverse {
        //  Check type.
        if m_Inner.type == .dictionary {
            throw VRCTraverseError(
                message: "Value should be a dictionary.",
                kind: .typeError, path: m_Path)
        }

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
                    kind: .unknownTypeError, path: subPath)
            }
            return VRCTraverse(inner: JSON(subInner), path: subPath)
        }
        
        return VRCTraverse(inner: subInner, path: subPath)
    }
    
    ///
    ///  Assume that inner object is not 'NULL'.
    ///
    ///  - Throws: Raised if inner object is 'NULL'.
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
    ///  Get item of array.
    ///
    ///  - Throws: Raised in the following situations:
    ///
    ///             - The inner object is 'NULL'.
    ///             - The inner object is not array.
    ///             - The offset is out of range.
    ///
    ///  - Parameter offset: The offset of item within array.
    ///
    ///  - Returns: Traverse object of item.
    ///
    public func arrayGetItem(offset: Int) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().typeOf(type: .arrayType)
        
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
    ///             - The inner object is 'NULL'.
    ///             - The inner object is not an array.
    ///
    ///  - Parameter handler: The callback.
    ///
    ///  - Returns: Self.
    ///
    public func arrayForEach(
        handler: (VRCTraverse) -> Void) throws -> VRCTraverse {
        //  Check type.
        _ = try self.notNull().typeOf(type: .arrayType)
        
        //  Scan all items.
        for i in 0..<m_Inner.arrayValue.count {
            let newInner = m_Inner[i]
            handler(VRCTraverse(
                inner: newInner, path: self.getSubPath(offset: i)))
        }
        
        return self
    }
    
    ///
    ///  Get inner object as unsigned int8.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The unsigned int8.
    ///
    public func innerAsUInt8() throws -> UInt8 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.uInt8Value
    }
    
    ///
    ///  Get inner object as signed int8.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The signed int8.
    ///
    public func innerAsSInt8() throws -> Int8 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.int8Value
    }
    
    ///
    ///  Get inner object as unsigned int16.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The unsigned int16.
    ///
    public func innerAsUInt16() throws -> UInt16 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.uInt16Value
    }
    
    ///
    ///  Get inner object as signed int16.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The signed int16.
    ///
    public func innerAsSInt16() throws -> Int16 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.int16Value
    }
    
    ///
    ///  Get inner object as unsigned int32.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The unsigned int32.
    ///
    public func innerAsUInt32() throws -> UInt32 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.uInt32Value
    }
    
    ///
    ///  Get inner object as signed int32.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The signed int32.
    ///
    public func innerAsSInt32() throws -> Int32 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.int32Value
    }
    
    ///
    ///  Get inner object as unsigned int64.
    ///
    ///  - Throws; Raised if inner object is not a integer.
    ///
    ///  - Returns: The unsigned int64 value.
    ///
    public func innerAsUInt64() throws -> UInt64 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.uInt64Value
    }
    
    ///
    ///  Get inner object as signed int64.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The signed int64 value.
    ///
    public func innerAsSInt64() throws -> Int64 {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.int64Value
    }
    
    ///
    ///  Get inner object as signed integer.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The integer value.
    ///
    public func innerAsInt() throws -> Int {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.intValue
    }
    
    ///
    ///  Get inner object as unsigned integer.
    ///
    ///  - Throws: Raised if inner object is not a integer.
    ///
    ///  - Returns: The unsigned integer value.
    ///
    public func innerAsUInt() throws -> UInt {
        //  Check type.
        _ = try self.integer()
        
        return m_Inner.uIntValue
    }
    
    ///
    ///  Get inner object as double.
    ///
    ///  - Throws: Raised if inner object is not numeric
    ///
    ///  - Returns: The double value.
    ///
    public func innerAsDouble() throws -> Double {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.doubleValue
    }
    
    ///
    ///  Get inner object as float.
    ///
    ///  - Throws: Raised if inner object is not numeric
    ///
    ///  - Returns: The float value.
    ///
    public func innerAsFloat() throws -> Float {
        //  Check type.
        _ = try self.numeric()
        
        return m_Inner.floatValue
    }
    
    ///
    ///  Get inner objet as string.
    ///
    ///  - Throws: Raised if inner object is not string.
    ///
    ///  - Returns: The string value.
    ///
    public func innerAsString() throws -> String {
        //  Check type.
        _ = try self.string()
        
        return m_Inner.stringValue
    }
}
