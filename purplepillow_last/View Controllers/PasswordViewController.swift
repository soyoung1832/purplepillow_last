import UIKit
import Firebase
import FirebaseFirestore

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    var email: String?
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        guard let password = passwordTextField.text, let confirmPassword = confirmTextField.text else {
            return
        }
        
        if password == confirmPassword {
            print("전달된 이메일: \(self.email ?? "없음")") // 디버깅 메시지
            print("전달된 유저명: \(self.username ?? "없음")") // 디버깅 메시지
            
            Auth.auth().createUser(withEmail: email!, password: password) { (firebaseResult, error) in
                if let error = error {
                    print("회원가입에 실패하였습니다. Error: \(error.localizedDescription)")
                } else {
                    print("회원가입에 성공하였습니다.")
                    
                    // Save user's additional information to Firebase database
                    let user = Auth.auth().currentUser
                    if let uid = user?.uid {
                        let userData: [String: Any] = [
                            "email": self.email!,
                            "username": self.username!
                            // Add more fields as needed
                        ]
                        
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData(userData) { error in
                            if let error = error {
                                print("사용자 정보 저장에 실패하였습니다. Error: \(error.localizedDescription)")
                            } else {
                                print("사용자 정보를 Firebase에 저장하였습니다.")
                                // Perform any necessary navigation or UI updates here
                            }
                        }
                    }
                }
            }
        } else {
            print("비밀번호가 일치하지 않습니다.")
        }
    }
    // ...
}
