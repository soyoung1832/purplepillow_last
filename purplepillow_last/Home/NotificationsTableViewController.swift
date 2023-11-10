import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class NotificationsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchFriendRequests()
    }

    var userProfiles: [UserProfile] = [] // 이 배열에 상대방의 프로필 정보를 저장합니다

    // Firestore에서 친구 요청 데이터 가져오기
    func fetchFriendRequests() {
        let auth = Auth.auth()
        let db = Firestore.firestore()
        let currentUserUID = auth.currentUser?.uid
        
        let friendRequestsRef = db.collection("follow_requests").whereField("toUserId", isEqualTo: currentUserUID)

        friendRequestsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching friend requests: \(error.localizedDescription)")
            } else {
                // Successful fetch
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let toUserId = data["fromUserId"] as? String
                    // toUserId를 사용하여 상대방의 프로필 정보를 가져옵니다.
                    self.fetchUserProfile(for: toUserId)
                }
            }
        }
    }

    // 상대방의 프로필 정보 가져오기
    func fetchUserProfile(for userId: String?) {
        guard let userId = userId else { return }
        
        let db = Firestore.firestore()
        let userProfileRef = db.collection("userProfiles").document(userId)

        userProfileRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let userProfile = UserProfile(data: data ?? [:])
               
                self.userProfiles.append(userProfile)
                self.tableView.reloadData()
            } else {
                print("User profile document not found.")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsTableViewCell
        let userProfile = userProfiles[indexPath.row]
        cell.configure(with: userProfile)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0 // 셀의 높이를 70 포인트로 설정
    }

}
