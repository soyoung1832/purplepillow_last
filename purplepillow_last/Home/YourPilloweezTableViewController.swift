import UIKit
import Firebase
import FirebaseFirestore

class YourPilloweezTableViewController: UITableViewController {
    var userProfiles: [UserProfile] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "YpurPilloweezTableViewCell", bundle: nil), forCellReuseIdentifier: "YourPilloweezTableCell")
        fetchAllUserProfiles()
    }

    func fetchAllUserProfiles() {
      
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("userProfiles").document(currentUserUID).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self, let document = documentSnapshot, document.exists else {
                return
            }
            
            let data = document.data() as? [String: Any] ?? [:]
            
            if let pilloweezUIDs = data["pilloweez"] as? [String] {
                for uid in pilloweezUIDs {
                    self.fetchUserProfile(for: uid)
                }
            }
        }
    }

    func fetchUserProfile(for uid: String) {
        
        db.collection("userProfiles").document(uid).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self, let document = documentSnapshot, document.exists else {
                return
            }
            
            let data = document.data() as? [String: Any] ?? [:]
            let userProfile = UserProfile(data: data)
            
            // userProfile을 데이터 소스에 추가
            self.userProfiles.append(userProfile)
            
            // 데이터를 가져온 후, 테이블 뷰를 리로드
            self.tableView.reloadData()
        }
    }

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourPilloweezTableCell", for: indexPath) as! YpurPilloweezTableViewCell
        let userProfile = userProfiles[indexPath.row]
        cell.configure(with: userProfile)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0 // 셀의 높이를 70 포인트로 설정
    }
}
