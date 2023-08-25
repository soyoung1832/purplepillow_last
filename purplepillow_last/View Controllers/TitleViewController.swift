import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class TitleViewController: UIViewController {

    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var posts: [Post] = []
    fileprivate var currentUserProfile: UserProfile?
    var db: Firestore!
    var auth: Auth!
    var storage: Storage!
    var userProfileListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.height / 2
        ProfileImageView.layer.borderWidth = 1
        ProfileImageView.clipsToBounds = true
        ProfileImageView.layer.borderColor = UIColor.blue.cgColor

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        collectionView.dataSource = self
        collectionView.delegate = self

        let post1 = Post(image: UIImage(systemName: "house")!, text: "첫 번째 게시글 내용", timestamp: "2023-08-09")
        let post2 = Post(image: UIImage(systemName: "sparkle")!, text: "두 번째 게시글 내용", timestamp: "2023-08-10")
        let post3 = Post(image: UIImage(systemName: "moon")!, text: "세 번째 게시글 내용", timestamp: "2023-08-11")

        posts = [post1, post2, post3]

        db = Firestore.firestore()
        auth = Auth.auth()
        storage = Storage.storage()

        loadCurrentUserProfile()
    }

    func loadCurrentUserProfile() {
        if let uid = auth.currentUser?.uid {
            let userProfileRef = db.collection("userProfiles").document(uid)
            userProfileListener = userProfileRef.addSnapshotListener { documentSnapshot, error in
                if let document = documentSnapshot, document.exists {
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
                                        self.ProfileImageView.image = image
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
            UsernameTextField.text = currentUserProfile.username
            BioTextField.text = currentUserProfile.bio
        }
    }
    
    deinit {
        userProfileListener?.remove()
    }
}


// CollectionView data source and delegate extensions

extension TitleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCustomViewCell", for: indexPath)

        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = self.posts[indexPath.item].image
        }

        return cell
    }
}

extension TitleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.item]
        performSegue(withIdentifier: "DetailSegue", sender: selectedPost)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "DetailSegue" == id {
            if let detailVC = segue.destination as? DetailViewController,
               let selectedPost = sender as? Post {
                detailVC.post = selectedPost
            }
        }
    }
}
