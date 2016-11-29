//
//  FeedsTableViewCell.swift
//  ParseStarterProject-Swift
//
//  Created by Xin Zou on 11/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class FeedsTableViewCell: UITableViewCell {

    @IBOutlet weak var feedImg: UIImageView!
    
    @IBOutlet weak var msgTextView: UITextView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
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
