//
//  LastCollectionViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/28.
//

import UIKit

class LastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backImg: UIImageView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        // UICollectionViewCell에 그림자 추가
        backImg.layer.cornerRadius = 10
        
        backImg.clipsToBounds = true
        backImg.layer.borderColor = UIColor.lightGray.cgColor
        
        backImg.layer.borderWidth = 0.5
        
    }
}
