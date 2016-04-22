//
//  GamesBundle.swift
//  OpenBrain
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
    
    lazy public private(set) var manifest:[[String:String]] = {
        
        //seed the rand function
        srand(UInt32( time(nil) ))
        
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
        
        guard let m = result as? [[String:String]] else {
            return [];
        }
        
        return m
        
    }()
    
    public func getResolvedManifest() -> [[String:String]] {
        var result:[[String:String]] = []
        
        for var item in self.manifest {
            if let url = self.URL(item, baseURL: self.bundleURL)?.absoluteString {
                item["url"] = url
                result.append(item)
            }
        }
        
        return result
    }
    
    func URL(item:[String:AnyObject], baseURL:NSURL?) -> NSURL? {
        guard let url = baseURL else{
            return nil
        }
        guard let filename = item["filename"] as? String else{
            return nil
        }
        return url.URLByAppendingPathComponent(filename)
    }
}
