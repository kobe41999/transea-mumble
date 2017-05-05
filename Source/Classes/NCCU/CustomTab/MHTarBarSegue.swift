//
//  MHTarBarSegue.swift
//  Mumble
//
//  Created by 林子傑 on 2017/4/24.
//
//

import Foundation
import UIKit


class MHTabBarSegue : UIStoryboardSegue {
    
    override func perform() {
        var tabBarViewController = (self.sourceViewController as! MHCustomTabBarController)
        var destinationViewController = (tabBarViewController.destinationViewController as! UIViewController)
        //remove old viewController
        if tabBarViewController.oldViewController {
            tabBarViewController.oldViewController.willMoveToParentViewController(nil)
            tabBarViewController.oldViewController.view.removeFromSuperview()
            tabBarViewController.oldViewController.removeFromParentViewController()
        }
        destinationViewController.view.frame = tabBarViewController.container.bounds
        tabBarViewController.addChildViewController(destinationViewController)
        tabBarViewController.container.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(tabBarViewController)
    }
}
