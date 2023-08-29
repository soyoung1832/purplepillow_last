import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!

    let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.38, green: 0, blue: 1, alpha: 1)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("갤러리", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let myButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("마이", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var isExpanded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(floatingButton)
        view.addSubview(galleryButton)
        view.addSubview(myButton)
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -106),
            floatingButton.widthAnchor.constraint(equalToConstant: 56),
            floatingButton.heightAnchor.constraint(equalToConstant: 56),
            
            galleryButton.centerXAnchor.constraint(equalTo: floatingButton.centerXAnchor),
            galleryButton.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -20),
            galleryButton.widthAnchor.constraint(equalToConstant: 40),
            galleryButton.heightAnchor.constraint(equalToConstant: 40),
            
            myButton.centerXAnchor.constraint(equalTo: galleryButton.centerXAnchor),
            myButton.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: -100),
            myButton.widthAnchor.constraint(equalToConstant: 40),
            myButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(selectImageFromGallery), for: .touchUpInside)
        myButton.addTarget(self, action: #selector(myButtonTapped), for: .touchUpInside)

        backgroundImageView.image = UIImage(named: "Group863")
    }

    @objc func floatingButtonTapped() {
        if isExpanded {
            UIView.animate(withDuration: 0.3) {
                self.galleryButton.isHidden = true
                self.myButton.isHidden = true
                self.floatingButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.galleryButton.isHidden = false
                self.myButton.isHidden = false
                self.floatingButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
        }
        isExpanded.toggle()
    }
    
    @objc func selectImageFromGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            // 이미지를 9:16 비율로 자르기
            let croppedImage = cropImageToAspectRatio(image: editedImage, targetRatio: 9.0 / 16.0)
            // 선택한 이미지로 배경 이미지 설정
            backgroundImageView.image = croppedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            // 이미지를 9:16 비율로 자르기
            let croppedImage = cropImageToAspectRatio(image: originalImage, targetRatio: 9.0 / 16.0)
            // 선택한 이미지로 배경 이미지 설정
            backgroundImageView.image = croppedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    // 이미지를 지정한 비율로 자르는 함수
    func cropImageToAspectRatio(image: UIImage, targetRatio: CGFloat) -> UIImage? {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let currentRatio = imageWidth / imageHeight
        
        if currentRatio == targetRatio {
            return image
        }
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        if currentRatio > targetRatio {
            // 이미지가 너무 넓을 경우
            width = imageHeight * targetRatio
            height = imageHeight
            xOffset = (imageWidth - width) / 2.0
        } else {
            // 이미지가 너무 높을 경우
            width = imageWidth
            height = imageWidth / targetRatio
            yOffset = (imageHeight - height) / 2.0
        }
        
        let croppedRect = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        if let croppedCGImage = image.cgImage?.cropping(to: croppedRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return nil
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func galleryButtonTapped() {
        print("갤러리 버튼 클릭됨")
    }
    
    @objc func myButtonTapped() {
        print("마이 버튼 클릭됨")
    }
}
