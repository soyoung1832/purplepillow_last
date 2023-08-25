import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var BioTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var currentUserProfile: UserProfile?
    var db: Firestore!
    var auth: Auth!
    var storage: Storage!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        auth = Auth.auth()
        storage = Storage.storage()
        
        loadCurrentUserProfile()
        
        // Initialize image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    func loadCurrentUserProfile() {
        if let uid = auth.currentUser?.uid {
            let userProfileRef = db.collection("userProfiles").document(uid)
            userProfileRef.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    if let unwrappedData = data {
                        let userProfile = UserProfile(data: unwrappedData)
                        self.currentUserProfile = userProfile
                        self.updateUI()
                        
                        if let imageUrl = userProfile.imageUrl, let url = URL(string: imageUrl) {
                            URLSession.shared.dataTask(with: url) { data, response, error in
                                if let error = error {
                                    print("Error downloading profile image: \(error)")
                                    return
                                }
                                
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.profileImg.image = image
                                    }
                                }
                            }.resume()
                        }
                    } else {
                        print("User profile data is nil")
                    }
                } else {
                    print("User profile document does not exist")
                }
            }
        }
    }
    
    func updateUI() {
        if let currentUserProfile = currentUserProfile {
            NameTextField.text = currentUserProfile.username
            BioTextField.text = currentUserProfile.bio
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default) { _ in
            self.openCamera()
        }
        let selectPhotoAction = UIAlertAction(title: "Select a Photo", style: .default) { _ in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(takePhotoAction)
        alertController.addAction(selectPhotoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Show loading indicator
        showLoadingIndicator()
        
        guard let uid = auth.currentUser?.uid, let username = NameTextField.text, let bio = BioTextField.text else {
            return
        }
        
        var data: [String: Any] = [
            "username": username,
            "bio": bio
            // Add more fields as needed
        ]
        
        if let image = profileImg.image, let imageData = image.jpegData(compressionQuality: 0.7) {
            let imageName = "\(uid)_profile_image.jpg"
            let storageRef = storage.reference().child("profile_images/\(imageName)")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error)")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        data["imageUrl"] = downloadURL.absoluteString
                        self.updateUserProfile(uid: uid, data: data)
                    }
                }
            }
        } else {
            self.updateUserProfile(uid: uid, data: data)
        }
    }
    
    func updateUserProfile(uid: String, data: [String: Any]) {
        let userProfileRef = db.collection("userProfiles").document(uid)
        
        userProfileRef.setData(data) { error in
            if let error = error {
                print("Error saving user profile: \(error)")
            } else {
                print("User profile saved successfully")
                self.navigationController?.popViewController(animated: true) // Go back to previous screen
            }
            // Hide loading indicator
            self.hideLoadingIndicator()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            profileImg.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        saveButton.customView = activityIndicator
        saveButton.isEnabled = false
    }
    
    func hideLoadingIndicator() {
        saveButton.customView = nil
        saveButton.isEnabled = true
    }
}
