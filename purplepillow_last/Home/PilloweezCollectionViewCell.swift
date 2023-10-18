//
//  PilloweezCollectionViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/15.
//

import UIKit

class PilloweezCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Main: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Main.layer.cornerRadius = 30    }

}
