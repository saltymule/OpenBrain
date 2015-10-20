//
//  GamesBundleUnitTests.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/19/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import XCTest
import ActivWiki

class GamesBundleUnitTests: XCTestCase {
    
    func testManifest() {
        
        let bundle = GamesBundle.gamesBundle()
        
        XCTAssert(bundle!.manifest.count > 0)
        
    }
    
    func testNextItem() {
        let bundle = GamesBundle.gamesBundle()
        
        XCTAssertNotNil(bundle?.nextItem())
    }
    
}
