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
        
        let jsCodeLocation = self.getJSURL()
        let props = ["localManifestURL":localManifestPath]
        
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
        
        if(self.isSimulator()){
            jsCodeLocation = NSURL(string:"http://localhost:8081/index.ios.bundle?platform=ios&dev=true");
        }else{
            jsCodeLocation = NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle")
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

