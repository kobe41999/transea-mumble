//
//  HistoryCellTableViewCell.swift
//  Mumble
//
//  Created by William on 2017/4/27.
//
//

import UIKit
import HCSStarRatingView

class HistoryCellTableViewCell: UITableViewCell {
    
    @IBOutlet var rating: HCSStarRatingView!
    @IBOutlet var labelDuration: UILabel!
    @IBOutlet var labelExpert: UILabel!
    @IBOutlet var labelDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    deinit {
    }
    
}


