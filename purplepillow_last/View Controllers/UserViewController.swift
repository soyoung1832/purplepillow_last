//
//  UserViewController.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/09.
//

import UIKit
import Firebase
import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func userNextButton(_ sender: UIButton) {
        guard let username = userTextField.text, !username.isEmpty else {
            print("유저명을 입력하세요.")
            return
        }
        
        // Navigate to the next view controller (EmailViewController)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let emailVC = storyboard.instantiateViewController(withIdentifier: "EmailViewController") as? EmailViewController {
            navigationController?.pushViewController(emailVC, animated: true)
        }
    }
}

