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
    
    lazy private(set) var savedBundle:NSBundle? = {
        guard   let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else{
            return nil
        }
        
        let savedurl = NSURL(fileURLWithPath: documentspath).URLByAppendingPathComponent("saved")
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(savedurl, withIntermediateDirectories: true, attributes: nil)
            
        }catch _ {
            return nil
        }
        
        return NSBundle(URL: savedurl)
        
    }()
    
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
    
    public func nextItem() -> [String:AnyObject]? {
        return manifest.first
    }
    
    public func getHTMLString(item:[String:AnyObject]) -> String? {
        
        if let savedURL = self.URL(item, baseURL: self.savedBundle?.bundleURL){
            
            do{
                let string = try String(contentsOfURL: savedURL)
                return string
            }catch _ { }
        }
        
        if let bundledURL = self.URL(item, baseURL: self.bundleURL){
            
            do{
                let string = try String(contentsOfURL: bundledURL)
                return string
            }catch _ { }
        }
        
        return nil
        
    }
    
    public func setHTMLString( string:String, item:[String:AnyObject] ) -> Void {
        
        guard let htmlURL = self.URL(item, baseURL: self.savedBundle?.bundleURL) else {
            return
        }
        do{
            try string.writeToURL(htmlURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch _ { }
    }
    
    func URL(item:[String:AnyObject], baseURL:NSURL?) -> NSURL? {
        guard let url = baseURL else{
            return nil
        }
        guard let name = item["name"] as? String else{
            return nil
        }
        return url.URLByAppendingPathComponent(name)
    }
}
