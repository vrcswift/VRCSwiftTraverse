# VRCSwiftTraverse

The purpose of this library is to strictly check JSON objects in less code.

## Examples

For a JSON like that:

```
{
    "a": 12,
    "b": "This is a test string",
    "c": true,
    "d": [0, 1, 2, 3, 4, 5],
    "e": null
}
```

We can parse in a more elegant way, like that:

``` Swift
do {
    let root = try VRCTraverse.init(parseJSON: str)
                              .notNull()
                              .directory()
    let a = try root.sub("a")
                    .notNull()
                    .integer()
                    .innerAsSInt()
    let b = try root.sub("b")
                    .notNull()
                    .string()
                    .innerAsString()
    let c = try root.sub("c")
                    .notNull()
                    .boolean()
                    .innerAsBoolean()
    var d = [Int]()
    _ = try root.sub("d")
                .notNull()
                .array()
                .arrayForEach({ (item) in
                    d.append(try item.notNull()
                                     .integer()
                                     .innerAsSInt())
                })
    let e = try root.sub("e").innerAsOptionalString()
} catch {
    //  Do something to handle error.
}
```

## APIs

### (Class) VRCTraverse

#### (Constructor) VRCTraverse.init(data: Data, options: JSONSerialization.ReadingOptions)

Constructor with JSON data.

<u>Throws</u>:

- Raised if JSON data is invalid.

<u>Parameter(s)</u>:

- data (*Data*): The JSON data.
- options (*JSONSerialization.ReadingOptions*): The JSON serialization reading options. Default is '[]'.

#### (Constructor) VRCTraverse.init(_ object: Any)

Constructor with JSON object.

<u>Throws</u>:

- Raised if JSON object is invalid.

<u>Parameter(s)</u>:

- object (*Any*): The JSON object.

#### (Constructor) VRCTraverse.init(parseJSON jsonString: Any)

Constructor with JSON string.

<u>Throws</u>:

- Raised if JSON string is invalid.

<u>Parameter(s)</u>:

- jsonString (*Any*): The JSON string.

#### (Method) typeOf(_ type: VRCTraverseType) -> VRCTraverse

Check whether inner object matches this type.

<u>Throws</u>:

- Raised if inner object does not match this type.

<u>Parameter(s)</u>:

- type (*VRCTraverseType*): The type.

<u>Returns</u>:

- Self.

### (Method) numeric() -> VRCTraverse

Check whether inner object is a numeric.

<u>Throws</u>:

- Raised if inner object is not a numeric.

<u>Returns</u>:

- Self.

### (Method) integer() -> VRCTraverse

Check whether inner object is a integer.

<u>Throws</u>:

- Raised if inner object is not a integer.

<u>Returns</u>:

- Self.

### (Method) boolean() -> VRCTraverse

Check whether inner object is a boolean.

<u>Throws</u>:

- Raised if inner object is not a boolean.

<u>Returns</u>:

- Self.

### (Method) string() -> VRCTraverse

Check whether inner object is a string.

<u>Throws</u>:

- Raised if inner object is not a string.

<u>Returns</u>:

- Self.

### (Method) array() -> VRCTraverse

Check whether inner object is a array.

<u>Throws</u>:

- Raised if inner object is not a array.

<u>Returns</u>:

- Self.

### (Method) directory() -> VRCTraverse

Check whether inner object is a directory.

<u>Throws</u>:

- Raised if inner object is not a directory.

<u>Returns</u>:

- Self.

### (Method) sub(_ name: String) -> VRCTraverse

Get sub item of directory.

<u>Throws</u>:

Raised in the following situations:
 - The inner object is 'NULL'.
 - The inner object is no a directory.
 - Raised if sub path is not existed.

<u>Parameter(s)</u>:

- name(*String*): The name/key of sub item.

<u>Returns</u>:

- Traverse object of sub item.

### (Method) optionalSub(_ name: String, defaultValue: Any? = nil) -> VRCTraverse

Get sub item of directory, which can be non-existed.

<u>Throws</u>:

Raised in the following situations:
 - The inner object is 'NULL'.
 - The inner object is no a directory.

<u>Parameter(s)</u>:

- name(*String*): The name/key of sub item.
- defaultValue(*Any?*): The default value if sub item doesn't exist.

<u>Returns</u>:

- Traverse object of sub item.

### (Method) notNull() -> VRCTraverse

Check whether inner object is not a 'NULL'.

<u>Throws</u>:

- Raised if inner object is a 'NULL'.

<u>Returns</u>:

- Self.

### (Method) min(_ threshold: Any) -> VRCTraverse

Set minimum value threshold for inner object.

<u>Note</u>:

- What is expected: inner &gt;= threshold.

<u>Throws</u>:

Raised in following situations:
- The inner object and threshold are of different types.
- 'inner' &lt; 'threshold'.

<u>Parameter(s)</u>:

- threshold(*Any*): The threshold.

<u>Returns</u>:

- Self.

### (Method) minExclusive(_ threshold: Any) -> VRCTraverse

Set exclusive minimum value threshold for inner object.

<u>Note</u>:

- What is expected: inner &gt; threshold.

<u>Throws</u>:

Raised in following situations:
- The inner object and threshold are of different types.
- 'inner' &lt;= 'threshold'.

<u>Parameter(s)</u>:

- threshold(*Any*): The threshold.

<u>Returns</u>:

- Self.

### (Method) max(_ threshold: Any) -> VRCTraverse

Set maximum value threshold for inner object.

<u>Note</u>:

- What is expected: inner &lt;= threshold.

<u>Throws</u>:

Raised in following situations:
- The inner object and threshold are of different types.
- 'inner' &gt; 'threshold'.

<u>Parameter(s)</u>:

- threshold(*Any*): The threshold.

<u>Returns</u>:

- Self.

### (Method) maxExclusive(_ threshold: Any) -> VRCTraverse

Set exclusive maximum value threshold for inner object.

<u>Note</u>:

- What is expected: inner &lt; threshold.

<u>Throws</u>:

Raised in following situations:
- The inner object and threshold are of different types.
- 'inner' &gt;= 'threshold'.

<u>Parameter(s)</u>:

- threshold(*Any*): The threshold.

<u>Returns</u>:

- Self.

### (Method) arrayGetItem(_ offset: Int) -> VRCTraverse

Get item of array.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not an array.
 - The offset is out of range.

<u>Parameter(s)</u>:

- offset (*Int*): The offset of item within array.

<u>Returns</u>:

- Traverse object of item.

### (Method) arrayForEach(_ offset: handler: (VRCTraverse) throws -> Void) -> VRCTraverse

Iterating through array.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not an array.

<u>Parameter(s)</u>:

- handler (*Function*): The callback.

<u>Returns</u>:

- Self.

### (Method) innerAsSInt8() -> Int8

Get inner object as a signed 8-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The signed 8-bit integer.

### (Method) innerAsOptionalSInt8() -> Int8?

Get inner object as an optional signed 8-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional signed 8-bit integer.

### (Method) innerAsUInt8() -> UInt8

Get inner object as an unsigned 8-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 8-bit integer.

### (Method) innerAsOptionalUInt8() -> UInt8?

Get inner object as an optional unsigned 8-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional unsigned 8-bit integer.

### (Method) innerAsSInt16() -> Int16

Get inner object as a signed 16-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 16-bit integer.

### (Method) innerAsOptionalSInt16() -> Int16?

Get inner object as an optional signed 16-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional signed 16-bit integer.

### (Method) innerAsUInt16() -> UInt16

Get inner object as an unsigned 16-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 16-bit integer.

### (Method) innerAsOptionalUInt16() -> UInt16?

Get inner object as an optional unsigned 16-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional unsigned 16-bit integer.

### (Method) innerAsSInt32() -> Int32

Get inner object as a signed 32-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 32-bit integer.

### (Method) innerAsOptionalSInt32() -> Int32?

Get inner object as an optional signed 32-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional signed 32-bit integer.

### (Method) innerAsUInt32() -> UInt32

Get inner object as an unsigned 32-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 32-bit integer.

### (Method) innerAsOptionalUInt32() -> UInt32?

Get inner object as an optional unsigned 32-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional unsigned 32-bit integer.

### (Method) innerAsSInt64() -> Int64

Get inner object as a signed 64-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 64-bit integer.

### (Method) innerAsOptionalSInt64() -> Int64?

Get inner object as an optional signed 64-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional signed 64-bit integer.

### (Method) innerAsUInt64() -> UInt64

Get inner object as an unsigned 64-bit integer.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The unsigned 64-bit integer.

### (Method) innerAsOptionalUInt64() -> UInt64?

Get inner object as an optional unsigned 64-bit integer.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional unsigned 64-bit integer.

### (Method) innerAsDouble() -> Double

Get inner object as double.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The double value.

### (Method) innerAsOptionalDouble() -> Double?

Get inner object as an optional double.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional double value.

### (Method) innerAsFloat() -> Float

Get inner object as a float.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a numeric.

<u>Returns</u>:

- The float value.

### (Method) innerAsOptionalFloat() -> Float?

Get inner object as an optional float.

<u>Throws</u>:

- Raised if the inner object is not a numeric.

<u>Returns</u>:

- The optional float value.

### (Method) innerAsString() -> String

Get inner object as a string.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a string.

<u>Returns</u>:

- The string value.

### (Method) innerAsOptionalString() -> String?

Get inner object as an optional string.

<u>Throws</u>:

- Raised if the inner object is not a string.

<u>Returns</u>:

- The optional string value.

### (Method) innerAsBoolean() -> Bool

Get inner object as a boolean.

<u>Throws</u>:

Raised in following situations:
 - The inner object is a 'NULL'.
 - The inner object is not a boolean.

<u>Returns</u>:

- The boolean value.

### (Method) innerAsOptionalBoolean() -> Bool?

Get inner object as an optional boolean.

<u>Throws</u>:

- Raised if the inner object is not a boolean.

<u>Returns</u>:

- The optional boolean value.

### (Method) inner<T>() -> T

Get inner object.

<u>Throws</u>:

Raised in following situations:
 - It's not supported for the type.
 - Cannot get value as target type.

<u>Returns</u>:

- The inner object.