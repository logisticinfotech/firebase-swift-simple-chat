//
//  GroupListCell.swift
//  messagingapp
//
//  Created by Nishita on 04/09/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit

class GroupListCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
 
    @IBOutlet weak var btnSelect: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

