//
//  WebViewComponent.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 10/16/15.
//  Copyright © 2015 Daniel Mueller. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewComponentDelegate{
    func webViewComponentDidComplete(component:WebViewComponent, options:[String:AnyObject]?, message:String?)
}

enum Action: String{
    case None="none", Load="load", Complete="complete", ForceComplete="forcecomplete"
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
    
    private(set) var htmlString:String = ""

    private(set) var options:[String:AnyObject] = [:]

    func start(html:String, options:[String:AnyObject]){
        
        self.htmlString = html
        
        webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        
        self.options = options
        
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        guard let body = message.body as? [String:AnyObject],
            let actionString:String = body["action"] as? String,
            let action:Action = Action(rawValue: actionString) else{
                return
        }
        
        switch( action ){
        case .None:
            break
        case .Load:
            self.webView.evaluateJavaScript(self.getStartJavascript(), completionHandler: nil)
            break
        case .Complete:
            let options = body["options"] as? [String:AnyObject]
            let message = body["message"] as? String
            self.delegate?.webViewComponentDidComplete(self, options: options, message: message)
            break
        case .ForceComplete:
            self.delegate?.webViewComponentDidComplete(self, options:nil, message: nil)
            break
        }
    }
    
    private func getStartJavascript() -> String{
        
        var result = "start(null)"
        
        do{
            let data = try NSJSONSerialization.dataWithJSONObject(self.options, options: .PrettyPrinted)
            guard let stringOptions = String(data: data , encoding: NSUTF8StringEncoding) else {
                return result
            }
            result = "start("+stringOptions+")"
        }catch _ { }
        
        return result
        
    }
    
    func clear(){
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
    }
    
}

