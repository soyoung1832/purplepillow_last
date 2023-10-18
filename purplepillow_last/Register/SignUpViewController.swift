import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase



class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var emailStatusLabel: UILabel!
    @IBOutlet weak var passwordStatusLabel: UILabel!
    @IBOutlet weak var passwordConfirmStatusLabel: UILabel!
    
  

    var doneButtonOriginalY: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()

        emailTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)

        updateNextButton(willActive: false)

        passwordTextField.isSecureTextEntry = true
        passwordConfirmTextField.isSecureTextEntry = true

        emailStatusLabel.isHidden = true
        passwordStatusLabel.isHidden = true
        passwordConfirmStatusLabel.isHidden = true

        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func TFdidChanged(_ sender: UITextField) {
        let isAllFieldsFilled = !(emailTextField.text?.isEmpty ?? true)
            && !(passwordTextField.text?.isEmpty ?? true)
            && !(passwordConfirmTextField.text?.isEmpty ?? true)

        if isAllFieldsFilled && isValidPassword(passwordTextField.text ?? "") {
            updateNextButton(willActive: true)
        } else {
            updateNextButton(willActive: false)
        }

        if sender == emailTextField {
            let fullEmail = (emailTextField.text ?? "")
            let isValid = isValidEmail(fullEmail)
            emailStatusLabel.isHidden = isValid
            emailStatusLabel.text = isValid ? "Valid email." : "유효한 이메일 주소를 입력해주세요"
        }

        if sender == passwordTextField {
            let password = (passwordTextField.text ?? "")
            let isValid = isValidPassword(password)
            passwordStatusLabel.isHidden = isValid
            passwordStatusLabel.text = isValid ? "Valid password." : "영문,숫자,특수문자 조합 8자리 이상 입력하세요"
        }

        if sender == passwordConfirmTextField {
            let passwordsMatch = passwordTextField.text == passwordConfirmTextField.text
            passwordConfirmStatusLabel.isHidden = passwordsMatch
            passwordConfirmStatusLabel.text = passwordsMatch ? "Passwords match." : "비밀번호가 일치하지 않습니다."
        }
    }

    func updateNextButton(willActive: Bool) {
        if willActive {
            doneButton.isEnabled = true
            doneButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            doneButton.isEnabled = false
            doneButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }

    @IBAction func doneButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let passwordConfirm = passwordConfirmTextField.text else { return }

        let fullEmail = email

        if password == passwordConfirm && isValidPassword(password) && isValidEmail(fullEmail) {
            Auth.auth().createUser(withEmail: fullEmail, password: password) { authResult, error in
                if let error = error {
                    print("가입 실패: \(error.localizedDescription)")
                } else {
                    if let uid = Auth.auth().currentUser?.uid {
                        let userProfileRef = Firestore.firestore().collection("userProfiles").document(uid)
                        userProfileRef.setData([
                            "imageUrl": "",
                            "username": "",
                            "bio": "",
                            "uid": uid
                        ]){ error in
                            if let error = error {
                                print("사용자 프로필 생성 오류: \(error)")
                            }
                        }

                        // Firebase Realtime Database에 사용자 정보 추가
                        let databaseRef = Database.database().reference()
                        let usersRef = databaseRef.child("users")
                        let userRef = usersRef.child(uid)
                        userRef.setValue([
                            "email": fullEmail,
                            "uid": uid
                            // 필요한 정보를 추가할 수 있습니다.
                        ])
                    }

                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                }
            }
        } else {
            if password != passwordConfirm {
                print("비밀번호가 일치하지 않습니다.")
            } else {
                if !isValidPassword(password) {
                    print("비밀번호는 문자, 숫자 및 특수 문자를 혼합하여 8자 이상이어야 합니다.")
                } else {
                    print("모든 필드를 입력해 주세요.")
                }
            }
        }
    }
    
    func isValidEmail(_ fullEmail: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: fullEmail)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
