//
//  JSONUnitTests.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 4/6/16.
//  Copyright © 2016 Daniel Mueller. All rights reserved.
//

import XCTest
@testable import OpenBrain

class JSONUnitTests: XCTestCase {
    
    func test_invalid_json_object() {
        let def = "default"
        let result = JSONStringWithObject(["key":NSNumber(float:1/0)], defaultString:def)
        
        XCTAssertEqual(def, result)
    }
    
    func test_valid_json_object() {
        let def = "default"
        let result = JSONStringWithObject(["key":NSNumber(float:1)], defaultString:def)
        
        XCTAssertNotEqual(def, result)
        
    }
    
}
