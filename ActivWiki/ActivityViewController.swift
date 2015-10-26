//
//  ActivityViewController.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/14/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import SourceCodeEditor

class ActivityViewController: UIViewController, WebViewComponentDelegate {
    
    lazy var webViewComponent:WebViewComponent = WebViewComponent()
    
    lazy var gamesBundle:GamesBundle = GamesBundle.gamesBundle()!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webViewComponent.webView.frame = self.view.bounds
        
        self.webViewComponent.delegate = self
        
        self.view.addSubview( self.webViewComponent.webView )
        
        self.loadNextActivity()
    }
    
    var bundleItem:[String:AnyObject]? = nil
    
    func loadNextActivity(){
        
        bundleItem = self.gamesBundle.nextItem()
        
        guard let item = bundleItem, let string = self.gamesBundle.getHTMLString(item) else  {
            return
        }
        
        self.webViewComponent.htmlString = string
        
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
    
    func webViewComponentDidComplete(component: WebViewComponent) {
        //show completion screen
        
        let controller = UIAlertController(title: "Menu", message: "Game Ended", preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { (action) -> Void in
            self.editActivity()
        }))
        
        controller.addAction(UIAlertAction(title: "Next", style: .Default, handler: { (action) -> Void in
            self.loadNextActivity()
        }))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}

