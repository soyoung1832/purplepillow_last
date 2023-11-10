import UIKit

class VerticalCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!

    var visitButtonAction: ((String) -> Void)?

    
    var userProfile: UserProfile? // 사용자 프로필 정보 저장용 변수

    @IBOutlet weak var visitBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImg.layer.cornerRadius = 40
        profileImg.layer.borderWidth = 1
        profileImg.clipsToBounds = true
        profileImg.layer.borderColor = UIColor.blue.cgColor

        // UICollectionViewCell에 그림자 추가
        backImg.layer.cornerRadius = 10
           
        backImg.clipsToBounds = true
        backImg.layer.borderColor = UIColor.lightGray.cgColor
        
        backImg.layer.borderWidth = 0.5
        
    }
   

     
    @IBAction func visitButtonTapped(_ sender: UIButton) {
           visitButtonAction?(userProfile?.uid ?? "")
        
        print(userProfile?.uid )
       }
    
    func configure(with userProfile: UserProfile) {
        if let imageUrl = userProfile.imageUrl, let url = URL(string: imageUrl) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImg.image = image
                    }
                }
            }
            task.resume()
        }
        usernameLabel?.text = userProfile.username ?? "DefaultUsername"
        bioLabel?.text = userProfile.bio ?? "DefaultBio"
    }
    
    
}

