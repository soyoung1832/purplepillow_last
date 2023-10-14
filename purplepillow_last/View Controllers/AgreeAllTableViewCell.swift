//
//  AgreeAllTableViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/13.
//

import UIKit

class AgreeAllTableViewCell: UITableViewCell {

    @IBOutlet weak var checkAllButton: UIButton!
    @IBOutlet weak var AgreeLabel: UILabel!


        override func awakeFromNib() {
            super.awakeFromNib()
            configureCheckAllButton(isChecked: false) // 초기 상태에서는 체크되지 않은 상태로 설정
            checkAllButton.addTarget(self, action: #selector(checkAllButtonTapped), for: .touchUpInside)
        }

        func configureCheckAllButton(isChecked: Bool) {
            let imageName = isChecked ? "checkmark.circle.fill" : "checkmark.circle.fill"
            let image = UIImage(systemName: imageName)
            checkAllButton.setImage(image, for: .normal)
            checkAllButton.tintColor = isChecked ? .purple : .lightGray
        }

        @objc func checkAllButtonTapped() {
            let isChecked = !checkAllButton.isSelected
            checkAllButton.isSelected = isChecked
            configureCheckAllButton(isChecked: isChecked)
        }
    }


