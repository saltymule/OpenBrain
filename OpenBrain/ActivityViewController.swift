//
//  ActivityViewController.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 10/14/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit

func CGRectOffsetTop(rect:CGRect, offset:CGFloat) -> CGRect {
    var result = rect
    result.origin.y += offset
    result.size.height -= offset
    return result
}

class ActivityViewController: UIViewController, WebViewComponentDelegate {
    
    lazy var webViewComponent:WebViewComponent = WebViewComponent()
    
    lazy var gamesBundle:GamesBundle = GamesBundle.gamesBundle()!
    
    var application:UIApplication {
        get{
            return UIApplication.sharedApplication()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None;
        
        self.webViewComponent.webView.frame = CGRectOffsetTop(self.view.bounds, offset:20 )
        
        self.webViewComponent.delegate = self
        
        self.view.addSubview( self.webViewComponent.webView )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUIApplicationWillResignActiveNotification:", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.presentMenu("Greetings!", isFirst: true)
        
    }
    
    func handleUIApplicationWillResignActiveNotification(notification:NSNotification){
        self.webViewComponent.clear()
        self.presentMenu("Game Cancelled", isFirst: false)
    }
    
    var bundleItem:[String:AnyObject]? = nil
    
    func loadNextActivity(){
        
        if let item = self.gamesBundle.nextItem() {
            self.loadActivity(item)
        }
        
    }

    func loadActivity(item:[String:AnyObject]){
        
        //when we are running an activity, don't turn off the screen automatically
        self.application.idleTimerDisabled = true
        
        guard let string = self.gamesBundle.getHTMLString(item) else  {
            return
        }
        
        bundleItem = item
        
        let options  = self.loadOptions(item) ?? [:]
        
        self.webViewComponent.start(string, options:options)
        
    }

    func didTapSourceCodeCancelButton(sender:AnyObject?){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.loadNextActivity()
    }
    
    func webViewComponentDidComplete(component: WebViewComponent, options:[String:AnyObject]?, message:String?) {
        //show completion screen
        
        if let options = options {
            self.save(options, item: bundleItem)
        }
        
        self.presentMenu(message, isFirst: false)
        
        //when we show the menu, the screen can turn off automatically
        self.application.idleTimerDisabled = false
    }
    
    func presentMenu(message:String?, isFirst:Bool){
        let menuMessage = message ?? "Game Ended"
        
        let controller = UIAlertController(title: "Menu", message: menuMessage, preferredStyle: .ActionSheet)
        
        let startTitle = isFirst ? "Start" : "Next"
        
        controller.addAction(UIAlertAction(title: startTitle, style: .Default, handler: { (action) -> Void in
            self.loadNextActivity()
        }))
        
        controller.addAction(UIAlertAction(title: "Select", style: .Default, handler: { (action) -> Void in
            self.selectActivity()
        }))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func selectActivity(){
        
        let controller = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for item in self.gamesBundle.manifest {
            if let name = item["name"] as? String{
                controller.addAction(UIAlertAction(title: name, style: .Default, handler: { (action) -> Void in
                    self.loadActivity(item)
                }))
            }
        }
                
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func save(options:[String:AnyObject],item:[String:AnyObject]?){
        guard let item = item, let name = item["name"] as? String else{
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(options, forKey: name)
    }

    func loadOptions(item:[String:AnyObject]?)->[String:AnyObject]{
        guard let item = item,
            let name = item["name"] as? String,
            let options = NSUserDefaults.standardUserDefaults().objectForKey(name) as? [String:AnyObject] else{
            return self.defaultOptions(nil)
        }
        
        return self.defaultOptions(options)
        
    }
    
    func defaultOptions(options:[String:AnyObject]?)->[String:AnyObject]{
        let result:[String:AnyObject] = options ?? [:]
        
        return result
    }

}

