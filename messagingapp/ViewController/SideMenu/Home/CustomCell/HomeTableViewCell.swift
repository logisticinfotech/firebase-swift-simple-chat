//
//  HomeTableViewCell.swift
//  messagingapp
//
//  Created by Nishita on 13/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var lblUserName: UILabel!
    
    @IBOutlet var imgUserProfile: UIImageView!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
