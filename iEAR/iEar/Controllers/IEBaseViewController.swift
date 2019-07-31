//
//  IEBaseViewController.swift
//  iEar
//
//  Created by Developer on 27/10/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class IEBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    
    @IBOutlet var menuTableView: UITableView!
    
    @IBOutlet var viewBGTableView: UIView!
    
    @IBOutlet var containerViewMain: UIView!
    
    
    var menuFlagActive = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        menuTableView?.register(UINib(nibName: TABLECELL_MENU, bundle: nil), forCellReuseIdentifier: ID_MENU_TABLECELL)

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func sliderMenuAnimation(_ selected: Bool)
    {
        if selected
        {
            
            self.viewBGTableView.frame = CGRect(x: 0, y: self.viewBGTableView.frame.origin.y, width: 0, height: self.viewBGTableView.frame.size.height)
            self.menuTableView.frame = CGRect(x: 0, y: self.menuTableView.frame.origin.y, width: 0, height: self.menuTableView.frame.size.height)
            
            self.viewBGTableView.updateConstraints()
            self.menuTableView.updateConstraints()
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
                self.viewBGTableView.frame = CGRect(x: 0, y: self.viewBGTableView.frame.origin.y, width: 300, height: self.viewBGTableView.frame.size.height)
                self.menuTableView.frame = CGRect(x: 0, y: self.menuTableView.frame.origin.y, width: 300, height: self.menuTableView.frame.size.height)
                
                self.viewBGTableView.updateConstraints()
                self.menuTableView.updateConstraints()
                
            }, completion: { (_: Bool) -> Void in
                self.menuFlagActive = true
                //self.view.isUserInteractionEnabled = true
            })
        }
        else
        {
            
            self.menuTableView.frame = CGRect(x: 0, y: self.menuTableView.frame.origin.y, width: 300, height: self.menuTableView.frame.size.height)
            
            self.viewBGTableView.frame = CGRect(x: 0, y: self.viewBGTableView.frame.origin.y, width: 300, height: self.viewBGTableView.frame.size.height)
            
            //self.view.isUserInteractionEnabled = false
            self.menuTableView.updateConstraints()
            self.viewBGTableView.updateConstraints()
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
                
                self.menuTableView.frame = CGRect(x: 0, y: self.menuTableView.frame.origin.y, width: 240, height: self.menuTableView.frame.size.height)
                self.viewBGTableView.frame = CGRect(x: 0, y: self.viewBGTableView.frame.origin.y, width: 0, height: self.viewBGTableView.frame.size.height)
                
                self.menuTableView.updateConstraints()
                self.viewBGTableView.updateConstraints()
                
            }, completion: { (_: Bool) -> Void in
                
                self.menuTableView.frame = CGRect(x: 0, y: self.menuTableView.frame.origin.y, width: 0, height: self.menuTableView.frame.size.height)
                self.menuTableView.alpha = 1.0
                
                self.menuFlagActive = false
                self.view.isUserInteractionEnabled = true
            })
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
                
                self.menuTableView.alpha = 0.0
                self.menuTableView.updateConstraints()
                
            }, completion: { (_: Bool) -> Void in
                
            })
        }
    }
    
    
    @IBAction func btnClickedMenu(_ sender: Any) {
        if self.menuFlagActive == false
        {
            self.sliderMenuAnimation(true)
        }
        else
        {
            self.sliderMenuAnimation(false)
        }
    }
    
    func ff() {
        
    }
    
    
    // MENU TABLE VIEW
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let moreCell = tableView.dequeueReusableCell(withIdentifier: ID_MENU_TABLECELL) as! IEMenuListingTableViewCell
        moreCell.setTableViewCell(indexPathValue: indexPath)

        moreCell.selectionStyle = .none
        tableView.rowHeight = 60
        return moreCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        sliderMenuAnimation(false)
        
            switch(indexPath.row)
            {
            case 0 :
                self.reloadBaseController()
                break
            case 1 :
                self.loadRemoveControllerRequest()
                // Load Storyboard
                let storyboard = UIStoryboard(name: STOARY_MAIN, bundle: nil)
                // Instantiate View Controller
                let viewController = storyboard.instantiateViewController(withIdentifier: CONTROLLER_NOTIFYME) as! IENotifyMeViewController
                // Add View Controller as Child View Controller
                self.add(asChildViewController: viewController)
            break
            case 2 :
                self.loadRemoveControllerRequest()
                // Load Storyboard
                let storyboard = UIStoryboard(name: STOARY_MAIN, bundle: nil)
                // Instantiate View Controller
                let viewController = storyboard.instantiateViewController(withIdentifier: CONTROLLER_TIPS) as! IETipsViewController
                // Add View Controller as Child View Controller
                self.add(asChildViewController: viewController)
                break
            case 3 :
                self.loadRemoveControllerRequest()
                // Load Storyboard
                let storyboard = UIStoryboard(name: STOARY_MAIN, bundle: nil)
                // Instantiate View Controller
                let viewController = storyboard.instantiateViewController(withIdentifier: CONTROLLER_ABOUTUS) as! IEAboutUsViewController
                // Add View Controller as Child View Controller
                self.add(asChildViewController: viewController)
                break
                
            default:
                break
            }

    }
    
    func reloadBaseController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadViewFromNib()
        }
    }
}

