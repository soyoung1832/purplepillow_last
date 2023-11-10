import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class RegisterProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!

    var db: Firestore!
    var storage: Storage!
    var imagePicker = UIImagePickerController()
    
    var uid: String? // Initialize it with the user's UID

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.layer.borderWidth = 1
        profileImg.clipsToBounds = true
        profileImg.layer.borderColor = UIColor.blue.cgColor
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Initialize uid with the user's UID after authentication
        db = Firestore.firestore()

        uid = Auth.auth().currentUser?.uid
        storage = Storage.storage()

        let logoImageView = UIImageView(image: UIImage(named: "PurplePillow"))
        logoImageView.contentMode = .scaleAspectFit // 이미지가 크기에 맞게 비율 유지하도록 설정
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoImageView.image?.size.width ?? 0, height: logoImageView.image?.size.height ?? 0)
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.7) // 이미지 크기를 0.5배로 축소
        navigationItem.titleView = logoImageView

    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let image = profileImg.image, let imageData = image.jpegData(compressionQuality: 0.7) {
            let imageName = "\(uid ?? "")_profile_image.jpg"
            let storageRef = storage.reference().child("profile_images/\(imageName)")

            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error)")
                } else {
                    // Image uploaded successfully, get download URL
                    storageRef.downloadURL { url, error in
                        if let downloadURL = url {
                            let imageUrl = downloadURL.absoluteString
                            self.updateUserProfile(imageUrl: imageUrl)
                        }
                    }
                }
            }
        } else {
            print("No image selected")
        }
    }
    
    func updateUserProfile(imageUrl: String) {
        let userProfileRef = db.collection("userProfiles").document(uid ?? "")
        
        userProfileRef.setData(["imageUrl": imageUrl], merge: true) { error in
            if let error = error {
                print("Error saving user profile: \(error)")
            } else {
                print("User profile saved successfully")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // UIImagePickerController delegate methods to handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            profileImg.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
