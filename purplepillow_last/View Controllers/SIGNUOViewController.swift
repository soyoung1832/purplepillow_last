//
//  SIGNUOViewController.swift
//  purplepillow_last
//
//  Created by test on 2023/10/13.
//

import UIKit
import PanModal

class SIGNUOViewController: UIViewController {
    
    
    // ... 다른 코드
    @IBOutlet weak var AgreeButton: UIButton!
    

        
        
        
        func showTermsBottomSheet() {
            let bottomSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            bottomSheet.addAction(UIAlertAction(title: "전체 약관 동의", style: .default, handler: nil))
            bottomSheet.addAction(UIAlertAction(title: "이용약관 (필수)", style: .default, handler: nil))
            bottomSheet.addAction(UIAlertAction(title: "개인정보 보호정책 (필수)", style: .default, handler: nil))
            bottomSheet.addAction(UIAlertAction(title: "광고성 정보 수신 및 마케팅 활용 (선택)", style: .default, handler: nil))
            bottomSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    

