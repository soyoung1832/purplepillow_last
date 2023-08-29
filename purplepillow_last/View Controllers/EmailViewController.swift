import UIKit
import Firebase
import FirebaseFirestore

class EmailViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField2: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var emailStatusLabel: UILabel!
    @IBOutlet weak var passwordStatusLabel: UILabel!
    @IBOutlet weak var passwordConfirmStatusLabel: UILabel!
    var doneButtonOriginalY: CGFloat = 0.0
    
    @IBOutlet weak var donebarbutton: UIBarButtonItem!
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
        
        emailTextField.delegate = self
        emailTextField2.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            // 텍스트 필드의 키보드를 숨김
            self.view.endEditing(true)
        }
    
    func showCompletionAlert() {
            let alert = UIAlertController(title: "회원가입 완료", message: "회원가입이 성공적으로 완료되었습니다.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "확인", style: .default) { _ in
                // 확인 버튼을 누르면 창이 사라지도록 설정
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    
    
    @objc func TFdidChanged(_ sender: UITextField) {
        print("텍스트 변경 감지")
        print("text :", sender.text)
        
        // 4개 텍스트 필드가 채워졌는지, 비밀번호가 일치하고 조건을 충족하는지 확인.
        let isAllFieldsFilled = !(emailTextField.text?.isEmpty ?? true)
        && !(emailTextField2.text?.isEmpty ?? true)
        && !(passwordTextField.text?.isEmpty ?? true)
        && !(passwordConfirmTextField.text?.isEmpty ?? true)
        
        if isAllFieldsFilled && isValidPassword(passwordTextField.text ?? "") {
            updateNextButton(willActive: true)
        } else {
            updateNextButton(willActive: false)
        }
        
        if sender == emailTextField || sender == emailTextField2 {
            let fullEmail = (emailTextField.text ?? "") + "@" + (emailTextField2.text ?? "")
            let isValid = isValidEmail(fullEmail)
            emailStatusLabel.isHidden = isValid
            emailStatusLabel.text = isValid ? "유효한 이메일입니다." : "올바른 이메일 형식을 입력하세요."
        }
        
        if sender == passwordTextField {
            let password = (passwordTextField.text ?? "")
            
            let isValid = isValidPassword(password)
            passwordStatusLabel.isHidden = isValid
            passwordStatusLabel.text = isValid ? "유효한 비밀번호입니다." : "영문,숫자,특수문자 조합 8자리 이상 입력하세요."
        }
        
        
        if sender == passwordConfirmTextField {
            let passwordsMatch = passwordTextField.text == passwordConfirmTextField.text
            passwordConfirmStatusLabel.isHidden = passwordsMatch
            passwordConfirmStatusLabel.text = passwordsMatch ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다."
        }
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
    
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
            // 회원가입 로직 완료 후, 메시지 창을 띄워주는 함수 호출
            showCompletionAlert()
        }

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
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
                    print( "회원가입에 성공하였습니다.") // 스낵바 띄우기
                    
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
