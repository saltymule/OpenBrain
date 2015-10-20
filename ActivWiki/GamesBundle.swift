//
//  GamesBundle.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/19/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit

public class GamesBundle: NSBundle {
    
    public class func gamesBundle() -> GamesBundle?{
        guard let path = NSBundle.mainBundle().pathForResource("Games", ofType: "bundle") else{
            assertionFailure()
            return nil;
        }
        return GamesBundle(path: path)
        
    }
    
    
    lazy public private(set) var manifest:[[String:AnyObject]] = {
        
        guard let URL = self.URLForResource("manifest", withExtension: "json") else {
            assertionFailure()
            return [];
        }
        
        var result:AnyObject = []
        
        do{
            try result = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: URL)!, options: NSJSONReadingOptions.AllowFragments)
        }catch _ {
            return [];
        }
        
        guard let m = result as? [[String:AnyObject]] else {
            return [];
        }
        
        return m
        
    }()
    
    public func nextItem() -> NSURL? {
        guard   let item = manifest.first,
                let name:String = item["name"] as? String,
                let URL = self.URLForResource(name, withExtension: nil) else {
            return nil
        }
        return URL
    }
        
}
