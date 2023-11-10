import UIKit
import Firebase
import FirebaseAuth
import PanModal

class UserDetailViewController: UIViewController {

    let auth = Auth.auth()
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var pilloweezBtn: UIButton!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var explain: UILabel!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
  
    @objc func profileImgTapped() {
        print("Profile Image Tapped") // 확인을 위해 로그를 추가해 보세요

        // 클릭 이벤트 핸들러 내에서 데이터 전달 및 화면 전환을 수행
        let uid = post1?.uid
        if let currentUserUid = auth.currentUser?.uid {
            var storyboardName: String
            var viewControllerIdentifier: String

            if uid == currentUserUid {
                storyboardName = "Mypage"
                viewControllerIdentifier = "TitleViewController"
            } else {
                storyboardName = "Home"
                viewControllerIdentifier = "UserTitleViewController"
            }

            if let detailViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: viewControllerIdentifier) as? UIViewController {
                if let detailViewController = detailViewController as? TitleViewController {
                    // 선택한 게시물을 TitleViewController에 전달합니다.
                    // detailViewController.post1 = post1
                } else if let detailViewController = detailViewController as? UserTitleViewController {
                    // 선택한 게시물을 UserTitleViewController에 전달합니다.
                    detailViewController.visitedUserID = uid
                }
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }



    
    @IBAction func didTapRequestBtn(_ sender: Any) {
        
        let userId = post1?.uid
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
                return
            }

            let db = Firestore.firestore()
            let followRequestsRef = db.collection("follow_requests")

            // 이미 팔로우 신청을 보낸 경우 중복으로 보내지 않도록 확인
            followRequestsRef
                .whereField("fromUserId", isEqualTo: currentUserUID)
                .whereField("toUserId", isEqualTo: userId)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking duplicate follow request: \(error.localizedDescription)")
                    } else if querySnapshot?.documents.isEmpty == true {
                        // 중복된 팔로우 신청이 없을 경우에만 새로운 팔로우 신청을 Firestore에 추가
                        let data: [String: Any] = [
                            "fromUserId": currentUserUID,
                            "toUserId": userId
                        ]

                        followRequestsRef.addDocument(data: data) { error in
                            if let error = error {
                                print("Error sending follow request: \(error.localizedDescription)")
                            } else {
                                print("Follow request sent successfully.")
                            }
                        }
                    }
                }
        pilloweezBtn.titleLabel?.text = "요청됨"
    }
    
    var post1: userPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        username.text = post1?.username
        timestamp.text = post1?.timestamp
        explain.text = post1?.explain
        loadProfile()
        loadPostImage()
        
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.layer.borderWidth = 1
        profileImg.clipsToBounds = true
        profileImg.layer.borderColor = UIColor.blue.cgColor
        
        postImg.layer.cornerRadius=10
        
        profileImg.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImgTapped))
        profileImg.addGestureRecognizer(tapGesture)
        
    
    }

    
    func loadProfile() {
        if let Profile = post1?.profile, let url = URL(string: Profile) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImg.image = image
                    }
                }
            }.resume()
        }
    }
    
    func loadPostImage() {
        if let imageUrl = post1?.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.postImg.image = image
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func onMorebuttonClicked(_ sender: UIBarButtonItem) {
            switch sender {
            case moreButton:
                let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(identifier: "MyTableVC") as! MyTableVC
                vc.modalPresentationStyle = .custom // 팝업 스타일 설정
                presentPanModal(vc)
            default:
                break
            }
        }
    }
