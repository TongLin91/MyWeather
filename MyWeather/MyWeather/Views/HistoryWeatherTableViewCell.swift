//
//  HistoryWeatherTableViewCell.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import UIKit

class HistoryWeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    static let cellIdentifier = "HistoryLocationCellIdentifier"
    
    override func prepareForReuse() {
        self.nameLabel.text = "Loading..."
        self.iconImageView.image = nil
        self.tempLabel.text = ""
        self.humLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
