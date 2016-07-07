//
//  AppDelegate.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 10/14/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import React

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
 
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool{
        
        guard let path = NSBundle.mainBundle().pathForResource("Games", ofType: "bundle"),
            let localManifestURL = NSBundle(path: path)?
                .URLForResource("manifest", withExtension: "json"),
            let localManifestPath = localManifestURL.path else{
            return false;
        }
        
        let forceLocal =  NSProcessInfo.processInfo().arguments.contains("--force-local")
        
        let jsCodeLocation = self.getJSURL()
        let props:[NSObject:AnyObject] = ["localManifestURL":localManifestPath, "forceLocal":forceLocal]
        
        let rootView = RCTRootView(bundleURL: jsCodeLocation,
                                   moduleName: "OpenBrain",
                                   initialProperties: props,
                                   launchOptions: launchOptions)
        
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        let rootViewController:MainViewController = MainViewController()
        rootViewController.view = rootView;
        self.window?.rootViewController = rootViewController;
        self.window?.makeKeyAndVisible()
                
        return true;
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    func getJSURL() -> NSURL {
        var jsCodeLocation:NSURL?
        
        let args = NSProcessInfo.processInfo().arguments
        //using a dev server requires adding NSAllowArbitraryLoads in
        //the info plist
        if  let index = args.indexOf("--dev-server") where  index + 1 < args.count {
            jsCodeLocation = NSURL(string:args[index+1]);
        }else{
            if let bundleAsset = NSUserDefaults.standardUserDefaults().objectForKey("bundleAsset") as? [String:AnyObject],
               let relativePath = bundleAsset["relativeLocalPath"] as? String
            {
                let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                jsCodeLocation = NSURL(fileURLWithPath: path+"/"+relativePath, isDirectory: false)
            }
            
            if jsCodeLocation == nil
            {
                jsCodeLocation = NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle")
            }
        }
        
        guard let location = jsCodeLocation else {
            assert(false, "no url found");
        }
        return location;

    }
    
    func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

