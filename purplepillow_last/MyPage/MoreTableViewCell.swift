//
//  MoreTableViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/11/01.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet weak var BtnLabel: UILabel!
    @IBOutlet weak var BtnImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
