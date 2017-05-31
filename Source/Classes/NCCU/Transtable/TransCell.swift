//
//  TransCell.swift
//  Mumble
//
//  Created by William on 2017/4/27.
//
//

import UIKit

class TransCell: UITableViewCell {
    
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var price: UILabel!
    
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

