//
//  PilloweezCollectionViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/15.
//

import UIKit

class PilloweezCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Main: UIImageView!

    func configure(with userPost: userPost) {
        if let imageUrl = userPost.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.Main.image = image
                    }
                }
            }.resume()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Main.layer.cornerRadius = 30
    }
}
