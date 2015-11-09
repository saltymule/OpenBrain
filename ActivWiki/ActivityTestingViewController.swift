//
//  ActivityTestingViewController.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/22/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import SourceCodeEditor

class ActivityTestingViewController: UIViewController , WebViewComponentDelegate, SourceCodeConsumer {
    
    lazy var webViewComponent:WebViewComponent = WebViewComponent()
    
    lazy var gamesBundle:GamesBundle = GamesBundle.gamesBundle()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webViewComponent.webView.frame = self.view.bounds
        
        self.webViewComponent.delegate = self
        
        self.view.addSubview( self.webViewComponent.webView )
        
    }
    
    var sourceCode:String?{
        didSet{
            if let sourceCode = self.sourceCode{
                self.webViewComponent.start(sourceCode,options:[:])
            }
        }
    }
    
    func webViewComponentDidComplete(component:WebViewComponent, options:[String:AnyObject]?){
        //show completion screen
        //Enable saving
    }
    
    @IBAction func didTapSaveButton(sender:AnyObject?){
        guard let controller = self.presentingViewController as? ActivityViewController else{
            return
        }
        controller.saveSourceCode()
    }
    
}
