//
//  IEMenuListingTableViewCell.swift
//  iEar
//
//  Created by developer on 03/11/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class IEMenuListingTableViewCell: UITableViewCell {


    @IBOutlet var imgMenu: UIImageView!
    
    @IBOutlet var lblMenuTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTableViewCell(indexPathValue: IndexPath) {
        switch(indexPathValue.row)
        {
        case 0 :
            lblMenuTitle.text = MENU_HOME
            imgMenu.image = UIImage.init(imageLiteralResourceName: "ic_home")
            break
        case 1 :
            lblMenuTitle.text = MENU_NOTIFY
            imgMenu.image = UIImage.init(imageLiteralResourceName: "ic_notify")
            break
            
        case 2 :
            lblMenuTitle.text = MENU_TIPS
            imgMenu.image = UIImage.init(imageLiteralResourceName: "ic_tips")
            break
            
        case 3 :
            lblMenuTitle.text = MENU_ABOUTUS
            imgMenu.image = UIImage.init(imageLiteralResourceName: "ic_aboutus")
            break
            
        default:
            break
        }

    }
    
    
}
