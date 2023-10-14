//
//  AgreeBottomSheetViewController.swift
//  purplepillow_last
//
//  Created by test on 2023/10/13.
//

import UIKit

class AgreeBottomSheetViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()

            // 바텀시트 내부 컨텐츠를 디자인합니다.
            let label = UILabel()
            label.text = "이용약관 동의"
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false

            let closeButton = UIButton(type: .system)
            closeButton.setTitle("닫기", for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            closeButton.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(label)
            view.addSubview(closeButton)

            // 레이아웃 설정
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                closeButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
                closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }

        @objc func closeButtonTapped() {
            dismiss(animated: true, completion: nil)
        }

}
