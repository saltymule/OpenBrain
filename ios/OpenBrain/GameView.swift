//
//  GameView.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 4/19/16.
//  Copyright © 2016 Daniel Mueller. All rights reserved.
//

import UIKit

@objc
protocol GameViewDelegate{
    func gameView(gameView:GameView, didCompleteWithOptions options:[String:AnyObject]?)
    func gameViewDidCancel(gameView:GameView)
}

class GameView: UIView, WebViewComponentDelegate  {
    
    weak var gameViewDelegate:GameViewDelegate?

    var data:[String:AnyObject]?{
        didSet{
            guard let game = self.data?["game"] as? [String:AnyObject],
                let relativeLocalPath = game["relativeLocalPath"] as? String else {
                    return
            }
            let url = self.documentsDirectory.URLByAppendingPathComponent(relativeLocalPath)
            let options:[String:AnyObject] = (self.data?["options"] as? [String:AnyObject]) ?? [:]
            
            self.webViewComponent.start(URL: url, baseURL:self.documentsDirectory, options: options)
        }
    }
    
    private var documentsDirectory:NSURL = {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return NSURL(fileURLWithPath: path, isDirectory: true)
    }()
    
    
    lazy var webViewComponent:WebViewComponent = WebViewComponent()
    
    var application:UIApplication {
        get{
            return UIApplication.sharedApplication()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview( self.webViewComponent.webView )
        
        self.webViewComponent.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameView.handleUIApplicationWillResignActiveNotification(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.webViewComponent.webView.frame = self.bounds
        
    }
    
    func handleUIApplicationWillResignActiveNotification(notification:NSNotification){
        self.webViewComponent.clear()
        self.gameViewDelegate?.gameViewDidCancel(self)
    }
    
    func loadActivity(item:[String:AnyObject]){
        
        //when we are running an activity, don't turn off the screen automatically
        self.application.idleTimerDisabled = true
        
//        self.webViewComponent.start(urlString, options:options)
        
    }
    
    func webViewComponentDidComplete(component: WebViewComponent, options:[String:AnyObject]?) {
        // callback options
        self.gameViewDelegate?.gameView(self, didCompleteWithOptions: options)
        //when we show the menu, the screen can turn off automatically
        self.application.idleTimerDisabled = false
    }
    
    
    
    
    
}

