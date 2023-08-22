//
//  RoundImageView.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/12.
//

import UIKit

@IBDesignable
class RoundImageView: UIImageView {

    override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = frame.width / 2
            clipsToBounds = true
        }

}
