//
//  VerticalDefaultCollectionViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/29.
//

import UIKit

class VerticalDefaultCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var itemImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backImg.layer.cornerRadius = 10
           
        backImg.clipsToBounds = true
        backImg.layer.borderColor = UIColor.lightGray.cgColor
        
        backImg.layer.borderWidth = 0.5
    }

}
