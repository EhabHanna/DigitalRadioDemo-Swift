//
//  HeaderViewCell.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class HeaderViewCell: UITableViewCell {

    @IBOutlet weak var headerTitleLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
