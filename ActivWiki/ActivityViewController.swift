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
    
    func loadNextActivity(){
        guard let URL = self.gamesBundle.nextItem() else {
            assertionFailure()
            return
        }
        
        do{
            let string = try String(contentsOfURL: URL)
            self.webViewComponent.htmlString = string
        }catch _ { }
    }
    
    func editActivity(){
        let controller = SourceCodeEditorViewController(nibName: nil, bundle: nil)
        
        controller.sourceCode = self.webViewComponent.htmlString
        
        self.presentViewController(controller, animated: true, completion: nil)
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

