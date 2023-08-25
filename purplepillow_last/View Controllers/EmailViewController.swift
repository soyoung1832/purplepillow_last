import UIKit
import Firebase
import FirebaseFirestore

class EmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField2: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var emailStatusLabel: UILabel!
    @IBOutlet weak var passwordStatusLabel: UILabel!
    @IBOutlet weak var passwordConfirmStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        emailTextField2.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(TFdidChanged(_:)), for: .editingChanged)
        
        updateNextButton(willActive: false)
        
        passwordTextField.isSecureTextEntry = true
        passwordConfirmTextField.isSecureTextEntry = true
        
        emailStatusLabel.isHidden = true
        passwordStatusLabel.isHidden = true
        passwordConfirmStatusLabel.isHidden = true
    }
    
    @objc func TFdidChanged(_ sender: UITextField) {
        // ... (이전 코드)
    }
    
    func updateNextButton(willActive: Bool) {
        if willActive {
            doneButton.setTitleColor(UIColor.white, for: .normal)
            print("다음 버튼 활성화")
        } else {
            doneButton.setTitleColor(UIColor.black, for: .normal)
            print("다음 버튼 비활성화")
        }
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let email2 = emailTextField2.text,
              let password = passwordTextField.text,
              let passwordConfirm = passwordConfirmTextField.text else { return }
        
        let fullEmail = email + "@" + email2
        
        if password == passwordConfirm && isValidPassword(password) && isValidEmail(fullEmail) {
            Auth.auth().createUser(withEmail: fullEmail, password: password) { firebaseResult, error in
                if let error = error {
                    print("회원가입에 실패하였습니다. Error: \(error.localizedDescription)")
                } else {
                    print("회원가입에 성공하였습니다.")
                    
                    Auth.auth().signIn(withEmail: fullEmail, password: password) { firebaseResult, error in
                        if let error = error {
                            print("로그인에 실패하였습니다. Error: \(error.localizedDescription)")
                        } else {
                            print("로그인에 성공하였습니다.")
                            
                            if let uid = Auth.auth().currentUser?.uid {
                                let userProfileRef = Firestore.firestore().collection("userProfiles").document(uid)
                                userProfileRef.setData([
                                    "imageUrl": "",
                                    "username": "",
                                    "bio": "",
                                    "uid": uid
                                ]) { error in
                                    if let error = error {
                                        print("Error creating user profile: \(error)")
                                    } else {
                                        print("User profile created successfully")
                                    }
                                }
                            }
                            
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            self.navigateToMainScreen()
                        }
                    }
                }
            }
        } else {
            if password != passwordConfirm {
                print("비밀번호가 일치하지 않습니다.")
            } else {
                if !isValidPassword(password) {
                    print("비밀번호는 영문, 숫자, 특수문자를 포함하여 8자리 이상이어야 합니다.")
                } else {
                    print("모든 텍스트 필드에 값을 입력하세요.")
                }
            }
        }
    }
    
    func isValidEmail(_ fullEmail: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: fullEmail)
    }
    
    
    // 비밀번호 유효성 검사 함수
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        return passwordPredicate.evaluate(with: password)
    }
    
    
    private func navigateToMainScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateInitialViewController()  {
                mainVC.modalPresentationStyle = .fullScreen
                present(mainVC, animated: true, completion: nil)
            }
        }
    }
