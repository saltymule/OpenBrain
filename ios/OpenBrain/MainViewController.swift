//
//  MainViewController.swift
//  OpenBrain
//
//  Created by Daniel Mueller on 4/19/16.
//  Copyright © 2016 Daniel Mueller. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape;
    }

}
