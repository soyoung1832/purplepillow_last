//
//  MyCustomViewCell.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/21.
//

import UIKit

class MyCustomViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImg: UIImageView!
    var didSelectCell: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func cellTapped() {
        didSelectCell?()
    }
}
