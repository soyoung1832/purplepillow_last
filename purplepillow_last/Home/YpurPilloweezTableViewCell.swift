import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class YpurPilloweezTableViewCell: UITableViewCell {
   
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
   
    var auth = Auth.auth()
    var UserId : String?
    var UserUid : String?

    
    
    func configure(with userProfile: UserProfile) {
       
        UserUid = userProfile.uid
        
        usernameLabel.text = userProfile.username
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        if let imageUrlString = userProfile.imageUrl, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async { [weak self] in
                        self?.profileImageView.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            // 이미지 URL이 nil인 경우에 대한 처리 (예: 기본 이미지 표시)
            self.profileImageView.image = UIImage(named: "defaultImage")
        }
    }
    @IBAction func didTabRemoveBtn(_ sender: Any) {
        
        UserId = auth.currentUser?.uid
        
        guard let currentUserUid = UserId, let targetUid = UserUid else {
            return
        }
        
        // Firestore 데이터베이스 참조
        let db = Firestore.firestore()
        let userProfilesRef = db.collection("userProfiles")
        
        // 현재 사용자의 문서에서 pilloweez 배열 가져오기
        userProfilesRef.document(currentUserUid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                var currentUserPilloweez = (document.data()?["pilloweez"] as? [String]) ?? []
                
                // 상대방의 UID를 배열에서 제거
                currentUserPilloweez = currentUserPilloweez.filter { $0 != targetUid }
                
                // 업데이트된 데이터를 현재 사용자의 문서에 저장
                userProfilesRef.document(currentUserUid).updateData(["pilloweez": currentUserPilloweez]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Pilloweez removed from current user successfully")
                    }
                }
            }
        }
        
        // 상대방의 문서에서 pilloweez 배열 가져오기
        userProfilesRef.document(targetUid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                var targetUserPilloweez = (document.data()?["pilloweez"] as? [String]) ?? []
                
                // 현재 사용자의 UID를 배열에서 제거
                targetUserPilloweez = targetUserPilloweez.filter { $0 != currentUserUid }
                
                // 업데이트된 데이터를 상대방의 문서에 저장
                userProfilesRef.document(targetUid).updateData(["pilloweez": targetUserPilloweez]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Pilloweez removed from target user successfully")
                    }
                }
            }
        }
    }

}
