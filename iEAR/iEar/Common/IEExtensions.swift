//
//  Extensions.swift
//  Oilco
//
//  Created by Vivek Anand John on 24/05/18.
//  Copyright © 2018 Vivek Anand John. All rights reserved.
//

import UIKit

import Foundation
import UIKit


extension UIViewController {
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
    
    func showCommonAlert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension IEBaseViewController {
    // MARK: - Navigation
    func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containerViewMain.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerViewMain.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func loadRemoveControllerRequest() {
        //Remove child view controllers
        for viewController in self.children {
            self.remove(asChildViewController: viewController)
        }
    }
    
}



