import UIKit
import AVFoundation
import UserNotifications

class AuthorityViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
        let logoImageView = UIImageView(image: UIImage(named: "PurplePillow"))
        logoImageView.contentMode = .scaleAspectFit // 이미지가 크기에 맞게 비율 유지하도록 설정
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoImageView.image?.size.width ?? 0, height: logoImageView.image?.size.height ?? 0)
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.7) // 이미지 크기를 0.5배로 축소
        navigationItem.titleView = logoImageView

            // Add an action to the Done button
            doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }

        @objc func doneButtonTapped() {
            
            self.navigateToMainScreen()
            requestCameraPermission()
        }
        
        func requestCameraPermission() {
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    // Camera access granted
                    self.requestNotificationPermission()
                } else {
                    // Camera access denied
                    // Handle the denial (e.g., show an alert)
                }
            }
        }
        
        func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    // Notification access granted
                    // You can now navigate to the main screen
                   
                } else {
                    // Notification access denied
                    // Handle the denial (e.g., show an alert)
                }
            }
        }

        private func navigateToMainScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateInitialViewController() {
                mainVC.modalPresentationStyle = .fullScreen
                present(mainVC, animated: true, completion: nil)
            }
        }
    }
