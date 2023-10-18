//
//  LoginViewController.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/09.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTexttField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        
        
        
    }
    
    @objc func TFdidChanged(_ sender: UITextField) {
        print("텍스트 변경 감지")
        print("text :", sender.text)
        
        // 4개 텍스트 필드가 채워졌는지, 비밀번호가 일치하고 조건을 충족하는지 확인.
        let isAllFieldsFilled = !(emailTexttField.text?.isEmpty ?? true)
            && !(passwordTextField.text?.isEmpty ?? true)
        
        
        if isAllFieldsFilled  {
            updateNextButton(willActive: true)
        } else {
            updateNextButton(willActive: false)
        }
        
    
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailTexttField.text,
              let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                print("로그인에 실패하였습니다. Error: \(error.localizedDescription)")
            } else {
                print("로그인에 성공하였습니다.")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.navigateToMainScreen()
            }
        
        }
        
    }
    
    
    private func navigateToMainScreen() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let mainVC = storyboard.instantiateInitialViewController()  {
               mainVC.modalPresentationStyle = .fullScreen
               present(mainVC, animated: true, completion: nil)
           }
       }
    
    func updateNextButton(willActive: Bool) {
        if willActive {
            // 다음 버튼 색 변경
            loginButton.setTitleColor(UIColor.white, for: .normal)
            // 다음 페이지 연결
            print("다음 버튼 활성화")
        } else {
            // 다음 버튼 색 변경
            loginButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    

}
