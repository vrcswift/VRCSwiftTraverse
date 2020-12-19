//
//  Copyright 2020 The VRC Authors. All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE.md file.
//

import XCTest
@testable import VRCSwiftTraverse

final class VRCSwiftTraverseTests: XCTestCase {
    let str = """
    {
        "a": 12,
        "b": "This is a test string",
        "c": true,
        "d": [
            0,
            1,
            2,
            3,
            4,
            5
        ],
        "e": null,
        "f": "key0"
    }
    """

    func testBasic() {
        do {
            var root = try VRCTraverse.init(parseJSON: str)
                                      .notNull()
                                      .typeOf(.dictionary)
                                      .directory()
            root = try VRCTraverse(root)
            let aobj = try root.sub("a")
                               .notNull()
                               .typeOf(.numeric)
                               .numeric()
                               .min(12)
                               .minExclusive(11)
                               .max(12)
                               .maxExclusive(13)
            
            XCTAssertEqual(try aobj.innerAsSInt8(), Int8(12))
            XCTAssertEqual(try aobj.innerAsUInt8(), UInt8(12))
            XCTAssertEqual(try aobj.innerAsSInt16(), Int16(12))
            XCTAssertEqual(try aobj.innerAsUInt16(), UInt16(12))
            XCTAssertEqual(try aobj.innerAsSInt32(), Int32(12))
            XCTAssertEqual(try aobj.innerAsUInt32(), UInt32(12))
            XCTAssertEqual(try aobj.innerAsSInt64(), Int64(12))
            XCTAssertEqual(try aobj.innerAsUInt64(), UInt64(12))
            XCTAssertEqual(try aobj.innerAsSInt(), Int(12))
            XCTAssertEqual(try aobj.innerAsUInt(), UInt(12))
            XCTAssertEqual(try aobj.innerAsFloat(), Float(12))
            XCTAssertEqual(try aobj.innerAsDouble(), Double(12))
            
            XCTAssertEqual(try aobj.inner(), Int8(12))
            XCTAssertEqual(try aobj.inner(), UInt8(12))
            XCTAssertEqual(try aobj.inner(), Int16(12))
            XCTAssertEqual(try aobj.inner(), UInt16(12))
            XCTAssertEqual(try aobj.inner(), Int32(12))
            XCTAssertEqual(try aobj.inner(), UInt32(12))
            XCTAssertEqual(try aobj.inner(), Int64(12))
            XCTAssertEqual(try aobj.inner(), UInt64(12))
            
            let bobj = try root.sub("b")
                               .notNull()
                               .typeOf(.string)
                               .string()
            XCTAssertEqual(try bobj.innerAsString(), "This is a test string")
            XCTAssertEqual(try bobj.inner(), "This is a test string")
            
            let cobj = try root.sub("c")
                               .notNull()
                               .typeOf(.boolean)
                               .boolean()
            XCTAssertEqual(try cobj.innerAsBoolean(), true)
            XCTAssertEqual(try cobj.inner(), Bool.init(true))
            
            let dobj = try root.sub("d")
                               .notNull()
                               .typeOf(.array)
                               .array()
            
            let fSelectObj = try root.sub("f")
                                     .notNull()
                                     .string()
                                     .selectFromDictionary(
                                            from: ["key0": 0, "key1": 1])
                                     .innerAsSInt()
            
            XCTAssertEqual(fSelectObj, 0)
            
            do {
                let _ = try root.sub("f")
                                .notNull()
                                .string()
                                .selectFromDictionary(from: ["k": 0])
                XCTFail()
            } catch let error as VRCTraverseError {
                XCTAssertEqual(error.kind, .keyNotFindError)
            } catch _ {
                XCTFail()
            }
            
            let fSelectObj2 = try root.sub("f")
                                      .notNull()
                                      .string()
                                      .selectFromDictionaryOptional(
                                            from: ["key0": 0, "key1": 1],
                                            defaultValue: -1)
                                      .innerAsSInt()
            
            XCTAssertEqual(fSelectObj2, 0)
            
            let fSelectObj3 = try root.sub("f")
                                      .notNull()
                                      .string()
                                      .selectFromDictionaryOptional(
                                        from: ["k": 0], defaultValue: -1)
                                      .innerAsSInt()
            
            XCTAssertEqual(fSelectObj3, -1)
            
            var index: Int = 0
            _ = try dobj.arrayForEach({ (item) in
                _ = try item.notNull().numeric()
                XCTAssertEqual(try item.innerAsSInt(), index)
                index += 1
            })
            
            XCTAssertFalse(dobj.isNull())
            XCTAssertEqual(try dobj.arrayGetItem(0).innerAsSInt(), 0)
            XCTAssertEqual(try dobj.arrayGetItem(1).innerAsSInt(), 1)
            XCTAssertEqual(try dobj.arrayGetItem(2).innerAsSInt(), 2)
            XCTAssertEqual(try dobj.arrayGetItem(3).innerAsSInt(), 3)
            XCTAssertEqual(try dobj.arrayGetItem(4).innerAsSInt(), 4)
            XCTAssertEqual(try dobj.arrayGetItem(5).innerAsSInt(), 5)
            
            let eobj = try root.optionalSub("e", defaultValue: nil)
            _ = try eobj.numeric()
                        .integer()
                        .string()
                        .array()
                        .directory()
                        .boolean()
                        .typeOf(.numeric)
                        .typeOf(.string)
                        .typeOf(.array)
                        .typeOf(.dictionary)
                        .typeOf(.boolean)
            
            XCTAssertTrue(eobj.isNull())
            XCTAssertEqual(try eobj.innerAsOptionalSInt8(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalUInt8(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalSInt16(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalUInt16(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalSInt32(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalUInt32(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalSInt64(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalUInt64(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalSInt(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalUInt(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalFloat(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalDouble(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalString(), nil)
            XCTAssertEqual(try eobj.innerAsOptionalBoolean(), nil)
                    
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testBasic", testBasic),
    ]
}
