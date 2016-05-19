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
    func webViewComponentDidComplete(component:WebViewComponent, options:[String:AnyObject]?)
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

    private(set) var URL:NSURL = NSURL()

    private(set) var options:[String:AnyObject] = [:]

  /// this is more or less deprecated
    func start(html:String, options:[String:AnyObject]){
        
        self.htmlString = html
        
        self.options = options
      
        webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        
    }

  func start(URL URL:NSURL, options:[String:AnyObject]){
    
    //we need the baseURL to allow read access
    guard let baseURL = URL.URLByDeletingLastPathComponent else {
      return
    }
    
    self.URL = URL
    
    self.options = options
    
    webView.loadFileURL(self.URL, allowingReadAccessToURL: baseURL)
    
    
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
            userContentController
            self.webView.evaluateJavaScript(self.getStartJavascript(), completionHandler: nil)
            break
        case .Complete:
          
            let options = self.getOptions(body)
            self.delegate?.webViewComponentDidComplete(self, options: options)
            break
        case .ForceComplete:
            self.delegate?.webViewComponentDidComplete(self, options:nil)
            break
        }
    }
  
  private func getOptions(body:[String:AnyObject]) -> [String:AnyObject]? {
    guard let options = body["options"] as? [String:AnyObject]
    where  NSJSONSerialization.isValidJSONObject(options) else {
      return nil
    }
    return options
  }
  
  private func getStartJavascript() -> String{
    let param = JSONStringWithObject(self.options, defaultString: "null")
    return "start(\(param))"
  }
  
  func clear(){
    self.webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
  }
  
}


public func JSONStringWithObject(object:AnyObject, defaultString:String) -> String{
  
  if !( NSJSONSerialization.isValidJSONObject(object)) {
    return defaultString
  }
  
  do{
    let data = try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
    guard let stringOptions = String(data: data , encoding: NSUTF8StringEncoding) else {
      return defaultString
    }
    return stringOptions
  }catch _ { }
  
  return defaultString
  
}
