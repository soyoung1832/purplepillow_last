//
//  TableViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/15.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var ContentsView: UICollectionView!
    @IBOutlet weak var Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
