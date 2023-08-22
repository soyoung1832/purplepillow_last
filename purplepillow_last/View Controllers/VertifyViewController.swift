//
//  VertifyViewController.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/10.
//

import UIKit
import Firebase

class VertifyViewController: UIViewController {

    @IBOutlet weak var verifyCodeTextField: UITextField!
    var email: String?
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        guard let verificationCode = verifyCodeTextField.text, !verificationCode.isEmpty else {
            print("인증 코드를 입력하세요.")
            return
        }
        
        // Verify the authentication code
        let credential = EmailAuthProvider.credential(withEmail: email!, password: verificationCode)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("인증 코드 확인에 실패하였습니다. Error: \(error.localizedDescription)")
            } else {
                print("인증 코드가 확인되었습니다.")
                
                // Navigate to the next view controller (PasswordViewController)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let passwordVC = storyboard.instantiateViewController(withIdentifier: "PasswordViewController") as? PasswordViewController {
                    passwordVC.username = self.username
                    passwordVC.email = self.email
                    self.navigationController?.pushViewController(passwordVC, animated: true)
                }
            }
        }
    }
}

