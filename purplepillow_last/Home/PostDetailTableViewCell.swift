//
//  PostDetailTableViewCell.swift
//  purplepillow_last
//
//  Created by test on 2023/10/30.
//

import UIKit

protocol PostDetailTableViewCellDelegate: AnyObject {
    func profileImageTapped(with userID: String)
}

class PostDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var Comment: UILabel!
    var userProfile: UserProfile? // userProfile 속성 추가
    
    weak var delegate: PostDetailTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 추가: 프로필 이미지에 탭 제스처 추가
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.addGestureRecognizer(profileImageTapGesture)
    }
    
    
    
    func configure(with userPost: userPost) {
        username.text = userPost.username
        Comment.text = userPost.explain
        ProfileImage.layer.cornerRadius = ProfileImage.frame.size.width / 2
        ProfileImage.clipsToBounds = true
        postImage.layer.cornerRadius = 5
        
        backImg.layer.cornerRadius = 10
        backImg.layer.shadowColor = UIColor.black.cgColor
        backImg.layer.shadowOpacity = 0.5
        backImg.layer.shadowOffset = CGSize(width: 2, height: 2)
        backImg.layer.shadowRadius = 4
        
        
        if let imageUrlString = userPost.profile, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async { [weak self] in
                        self?.ProfileImage.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            // 이미지 URL이 nil인 경우에 대한 처리 (예: 기본 이미지 표시)
            self.ProfileImage.image = UIImage(named: "defaultImage")
        }
        
        
        if let imageUrlString = userPost.imageUrl, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async { [weak self] in
                        self?.postImage.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            // 이미지 URL이 nil인 경우에 대한 처리 (예: 기본 이미지 표시)
            self.postImage.image = UIImage(named: "defaultImage")
        }
        
    }
    
    @objc func profileImageTapped() {
        if let userID = userProfile?.uid {
            delegate?.profileImageTapped(with: userID)
        }
        
    }
    
}
