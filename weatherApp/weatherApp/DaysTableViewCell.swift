//
//  DaysTableViewCell.swift
//  weatherApp
//
//  Created by katya on 15.09.22.
//

import UIKit

class DaysTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(dayOfWeek: String, temperatureMax: String) {
        labelDay.text = dayOfWeek
        maxTemperature.text = temperatureMax
    }
}
