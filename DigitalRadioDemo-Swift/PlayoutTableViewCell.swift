//
//  PlayoutTableViewCell.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class PlayoutTableViewCell: UITableViewCell, OnAirItemTableViewCell {

    @IBOutlet weak var playoutImageView:UIImageView!
    @IBOutlet weak var playoutTitleLabel:UILabel!
    @IBOutlet weak var playoutArtistLabel:UILabel!
    @IBOutlet weak var playoutDurationLabel:UILabel!
    @IBOutlet weak var playoutStartTimeLabel:UILabel!
    @IBOutlet weak var playoutTypeSongLabel:UILabel!
    @IBOutlet weak var playoutTypeUnknownLabel:UILabel!
    @IBOutlet weak var playoutStatusPlayingLabel:UILabel!
    @IBOutlet weak var playoutStatusHistoryLabel:UILabel!
    @IBOutlet weak var playoutStatusUnknownLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with playoutItem: onAirPlayoutItem) {
        
        self.playoutTitleLabel.text = playoutItem.title;
        self.playoutArtistLabel.text = playoutItem.artist;
        self.playoutStartTimeLabel.text = playoutItem.time(asStringWith: "E d MMM 'at' hh:mm a")
        self.playoutDurationLabel.text = playoutItem.duration(asStringWith: "mm:ss")
        
        self.playoutStatusPlayingLabel.isHidden = playoutItem.status == .playing ? false : true
        self.playoutStatusHistoryLabel.isHidden = playoutItem.status == .history ? false : true
        self.playoutStatusUnknownLabel.isHidden = playoutItem.status == .unknown ? false : true
        self.playoutTypeSongLabel.isHidden = playoutItem.type == .song ? false : true
        self.playoutTypeUnknownLabel.isHidden = playoutItem.type == .unknown ? false : true
        
    }
    
    func configure(with item: onAirDocumentItem) {
        
        if item is onAirPlayoutItem {
            configure(with: item as! onAirPlayoutItem)
        }
    }
    
    func update(image: UIImage?) {
        self.playoutImageView.image = image ?? UIImage(named: "defaultImage")
    }

}
