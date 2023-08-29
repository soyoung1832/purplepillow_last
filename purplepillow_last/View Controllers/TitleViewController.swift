import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class TitleViewController: UIViewController {

    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var studionum: UITextView!
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

        let post1 = Post(image: UIImage(named: "Group863"), text: "첫 번째 게시글 내용", timestamp: "2023-08-09")
        let post2 = Post(image: UIImage(named: "Group863"), text: "두 번째 게시글 내용", timestamp: "2023-08-10")
        let post3 = Post(image: UIImage(named: "Group863"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post4 = Post(image: UIImage(named: "Group863"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post5 = Post(image: UIImage(named: "Group863"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post6 = Post(image: UIImage(named: "Group863"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post7 = Post(image: UIImage(named: "Group863"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")

        posts = [post1, post2, post3,post4,post5,post6,post7]

        
        
        db = Firestore.firestore()
        auth = Auth.auth()
        storage = Storage.storage()

        loadCurrentUserProfile()
        
        self.collectionView.collectionViewLayout = createCompositionalLayoutForThird()
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

extension TitleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCustomViewCell", for: indexPath)

        cell.contentView.backgroundColor = .gray
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor

        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.contentMode = .center // Set the content mode to center
            imageView.image = self.posts[indexPath.item].image
        }

        return cell
    }
}

extension TitleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 10) / 2
        let cellHeight: CGFloat = 110
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // Add other UICollectionViewFlowLayoutDelegate methods if needed
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

//MARK: - 콜렉션뷰 콤포지셔널 레이아웃 관련
extension TitleViewController {
    
    // ... (다른 콜렉션뷰 레이아웃 생성 함수들도 포함하여 그대로 유지)
    
    fileprivate func createCompositionalLayoutForThird() -> UICollectionViewLayout {
        print("createCompositionalLayoutForThird() called")
        // 콤포지셔널 레이아웃 생성
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // 변경할 부분: 아이템 수를 3으로 변경
            let groupHeight =  NSCollectionLayoutDimension.fractionalWidth(1/2.5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            
            // 변경할 부분: 그룹 내의 아이템 수를 3으로 변경
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        }
        return layout
    }
}
