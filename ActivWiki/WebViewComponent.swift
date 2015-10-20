//
//  WebViewComponent.swift
//  ActivWiki
//
//  Created by Daniel Mueller on 10/16/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewComponentDelegate{
    func webViewComponentDidComplete(component:WebViewComponent)
}

enum Action: String{
    case None="none", Complete="complete", ForceComplete="forcecomplete"
};

class WebViewComponent: NSObject, WKScriptMessageHandler {
    
    var delegate:WebViewComponentDelegate? = nil
    
    func createWebView()->WKWebView{
        let config = WKWebViewConfiguration()
        
        config.userContentController = WKUserContentController()
        
        let webView = WKWebView(frame: CGRectZero, configuration: config)
        
        webView.scrollView.delaysContentTouches = false;
        webView.scrollView.scrollEnabled = false;
        webView.scrollView.bounces = false;
        
        config.userContentController.addScriptMessageHandler(self, name: "mediator")
        
        let filePath:String? = NSBundle.mainBundle().pathForResource("metacontroller", ofType: "js")
        
        if let filePath:String = filePath{
            let source = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            
            if let source = source{
                let userScript:WKUserScript = WKUserScript(
                    source: source as String,
                    injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
                    forMainFrameOnly: true
                )
                
                webView.configuration.userContentController.addUserScript(userScript)
            }
            
        }
        
        return webView
    }

    private(set) lazy var webView:WKWebView = {
        return self.createWebView()
    }()
    
    var htmlString:String = "" {
        didSet{
            webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        }
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let actionString:String = (message.body as? [String:AnyObject])?["action"] as? String {
            if let action:Action = Action(rawValue: actionString){
                switch( action ){
                case .None:
                    break
                case .Complete:
                    self.delegate?.webViewComponentDidComplete(self)
                    break
                case .ForceComplete:
                    self.delegate?.webViewComponentDidComplete(self)
                    break
                }
            }
        }
    }
    
}

