//
//  ActivityViewController.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/14/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import SourceCodeEditor

func CGRectOffsetTop(rect:CGRect, offset:CGFloat) -> CGRect {
    var result = rect
    result.origin.y += offset
    result.size.height -= offset
    return result
}

class ActivityViewController: UIViewController, WebViewComponentDelegate {
    
    lazy var webViewComponent:WebViewComponent = WebViewComponent()
    
    lazy var gamesBundle:GamesBundle = GamesBundle.gamesBundle()!
    
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
        
        bundleItem = self.gamesBundle.nextItem()
        
        guard   let item = bundleItem,
                let string = self.gamesBundle.getHTMLString(item) else  {
            return
        }
        
        let options  = self.loadOptions(item) ?? [:]
        
        self.webViewComponent.start(string, options:options)
        
    }
    
    func editActivity(){
        self.performSegueWithIdentifier("Edit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard   let navController:UINavigationController = segue.destinationViewController as? UINavigationController,
                let editorController:SourceCodeEditorViewController = navController.viewControllers.first as? SourceCodeEditorViewController else{
                return;
        }
        
        editorController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "didTapSourceCodeCancelButton:")
        
        editorController.sourceCode = self.webViewComponent.htmlString

    }
    
    func didTapSourceCodeCancelButton(sender:AnyObject?){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.loadNextActivity()
    }
    
    func saveSourceCode(){
        guard   let navController:UINavigationController = self.presentedViewController as? UINavigationController,
                let editorController:SourceCodeEditorViewController = navController.viewControllers.first as? SourceCodeEditorViewController,
                let item = bundleItem,
                let htmlString = editorController.sourceCode else{
                return;
        }
        
        self.gamesBundle.setHTMLString(htmlString, item: item)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.loadNextActivity()
    }
    
    func webViewComponentDidComplete(component: WebViewComponent, options:[String:AnyObject]?, message:String?) {
        //show completion screen
        
        if let options = options {
            self.save(options, item: bundleItem)
        }
        
        self.presentMenu(message, isFirst: false)
        
    }
    
    func presentMenu(message:String?, isFirst:Bool){
        let menuMessage = message ?? "Game Ended"
        
        let controller = UIAlertController(title: "Menu", message: menuMessage, preferredStyle: .ActionSheet)
//        
//        if !isFirst {
//            controller.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { (action) -> Void in
//                self.editActivity()
//            }))
//        }
        
        let startTitle = isFirst ? "Start" : "Next"
        
        controller.addAction(UIAlertAction(title: startTitle, style: .Default, handler: { (action) -> Void in
            self.loadNextActivity()
        }))
        
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

