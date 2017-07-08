//
//  OnAirItemTableViewCell.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import Foundation
import UIKit

protocol OnAirItemTableViewCell {
    
    func update(image:UIImage?)
    func configure(with item:onAirDocumentItem)
}
