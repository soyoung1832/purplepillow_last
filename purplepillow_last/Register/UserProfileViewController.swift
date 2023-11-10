import UIKit
import Firebase
import FirebaseFirestore

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImageView = UIImageView(image: UIImage(named: "PurplePillow"))
        logoImageView.contentMode = .scaleAspectFit // 이미지가 크기에 맞게 비율 유지하도록 설정
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoImageView.image?.size.width ?? 0, height: logoImageView.image?.size.height ?? 0)
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.7) // 이미지 크기를 0.5배로 축소
        navigationItem.titleView = logoImageView

    }
    
    @IBAction func uploadUserProfile(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            // 사용자가 로그인하지 않은 경우 처리
            return
        }
        
        // TextField에서 입력된 값 가져오기
        let userUsername = username.text ?? ""
        let userFirstName = firstName.text ?? ""
        let userLastName = lastName.text ?? ""
        
        // Firebase Firestore에 데이터 업로드
        let db = Firestore.firestore()
        let userProfileRef = db.collection("userProfiles").document(uid) // 콜렉션 이름 수정: "userProfiles"
        
        userProfileRef.setData([
            "lastname": userLastName,
            "firstname": userFirstName,
            "fullname": userLastName + userFirstName,
            "imageUrl": "",
            "username": userUsername,
            "bio": "",
            "uid": uid,
            "pilloweezCount": 0,
            "postCount": 0,
            "pilloweez": [:]
        ]) { error in
            if let error = error {
                print("사용자 프로필 정보를 업로드하는 동안 오류 발생: \(error.localizedDescription)")
            } else {
                print("사용자 프로필 정보가 성공적으로 업로드되었습니다.")
                // 업로드 성공 시 원하는 동작 수행
            }
        }
    }
}
