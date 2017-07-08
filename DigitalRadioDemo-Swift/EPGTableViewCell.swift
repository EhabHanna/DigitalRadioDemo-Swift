//
//  EPGTableViewCell.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class EPGTableViewCell: UITableViewCell, OnAirItemTableViewCell {
    
    @IBOutlet weak var epgImageView:UIImageView!
    @IBOutlet weak var epgTitleLabel:UILabel!
    @IBOutlet weak var epgPresenterLabel:UILabel!
    @IBOutlet weak var epgDurationLabel:UILabel!
    @IBOutlet weak var epgStartTimeLabel:UILabel!
    @IBOutlet weak var epgDescriptionLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with epgItem: onAirEPGItem){
        
        self.epgStartTimeLabel.text = epgItem.time(asStringWith: "E d MMM 'at' hh:mm a")
        self.epgDurationLabel.text = epgItem.duration(asStringWith: "H 'hrs' m 'mins'");
        self.epgTitleLabel.text = epgItem.name
        self.epgDescriptionLabel.text = epgItem.epgDescription
        if (epgItem.presenter?.isEmpty)! {
            self.epgPresenterLabel.text = epgItem.presenter;
            self.epgPresenterLabel.isHidden = false;
        }else{
            self.epgPresenterLabel.isHidden = true;
        }
        
    }
    
    func configure(with item: onAirDocumentItem) {
        if item is onAirEPGItem{
            configure(with: item as! onAirEPGItem)
        }
    }
    
    func update(image: UIImage?) {
        
        self.epgImageView.image = image ?? UIImage(named: "defaultImage")
    }

}
