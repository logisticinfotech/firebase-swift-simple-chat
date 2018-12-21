//
//  ChatTableViewCell.swift
//  messagingapp
//
//  Created by Nishita on 15/06/18.
//  Copyright © 2018 Nishita. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var lblReceiver: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

