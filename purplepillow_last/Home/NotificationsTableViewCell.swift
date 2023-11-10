import UIKit
import Firebase
import FirebaseFirestore

class NotificationsTableViewCell: UITableViewCell {
    
    var userId: String? // 사용자의 UID를 저장할 변수
    var tableView: UITableView? 
    
    @IBOutlet weak var UserProfileImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    func configure(with userProfile: UserProfile) {
        username.text = userProfile.username
        userId = userProfile.uid
        
        UserProfileImg.layer.cornerRadius = UserProfileImg.frame.size.width / 2
        UserProfileImg.clipsToBounds = true
        
        if let imageUrlString = userProfile.imageUrl, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async { [weak self] in
                        self?.UserProfileImg.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            // 이미지 URL이 nil인 경우에 대한 처리 (예: 기본 이미지 표시)
            self.UserProfileImg.image = UIImage(named: "defaultImage")
        }
    }
    
    @IBAction func didTapAcceptBtn(_ sender: Any) {
        guard let toUserId = userId else {
            return
        }

        print(toUserId)

        let auth = Auth.auth()

        guard let currentUserUID = auth.currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let batch = db.batch()
        let friendRequestsRef = db.collection("follow_requests")

        friendRequestsRef.whereField("toUserId", isEqualTo: currentUserUID).whereField("fromUserId", isEqualTo: toUserId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error deleting friend request: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    batch.deleteDocument(document.reference)
                }

                let currentUserFriendRef = db.collection("userProfiles").document(currentUserUID)
                let toUserFriendRef = db.collection("userProfiles").document(toUserId)

                // "pilloweez" 배열 업데이트
                batch.updateData(["pilloweez": FieldValue.arrayUnion([toUserId])], forDocument: currentUserFriendRef)
                batch.updateData(["pilloweez": FieldValue.arrayUnion([currentUserUID])], forDocument: toUserFriendRef)

                // "pilloweezCount" 필드 업데이트 (정수 값을 1 증가)
                batch.updateData(["pilloweezCount": 1], forDocument: currentUserFriendRef)
                batch.updateData(["pilloweezCount": 1], forDocument: toUserFriendRef)

                batch.commit { (error) in
                    if let error = error {
                        print("Error updating data: \(error.localizedDescription)")
                    } else {
                        print("Friend request accepted.")
                        // 테이블 뷰나 UI를 업데이트할 필요가 있다면 여기에서 수행하세요.
                    }
                }
            }
        }
    }



        
        @IBAction func didTapCancelBtn(_ sender: Any) {
            guard let toUserId = userId
            else {
                return
            }
            
            let auth = Auth.auth()
            guard let currentUserUID = auth.currentUser?.uid else {
                return
            }
            
            let db = Firestore.firestore()
            let friendRequestsRef = db.collection("follow_requests")
            
            friendRequestsRef.whereField("toUserId", isEqualTo: currentUserUID).whereField("fromUserId", isEqualTo: toUserId).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error deleting friend request: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                            } else {
                                print("Friend request rejected and deleted.")
                            }
                        }
                    }
                }
            }
            
            tableView?.reloadData()
        }
}
