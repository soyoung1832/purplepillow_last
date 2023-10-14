//
//  AgreeTableViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/13.
//

import UIKit
class AgreeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var checkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCheckButton(isChecked: false) // 초기 상태에서는 체크되지 않은 상태로 설정
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }

    func configureCheckButton(isChecked: Bool) {
        let imageName = isChecked ? "checkmark.circle.fill" : "checkmark.circle.fill"
        let image = UIImage(systemName: imageName)
        checkButton.setImage(image, for: .normal)
        checkButton.tintColor = isChecked ? .purple : .lightGray
    }

    @objc func checkButtonTapped() {
        let isChecked = !checkButton.isSelected
        checkButton.isSelected = isChecked
        configureCheckButton(isChecked: isChecked)
    }
}
