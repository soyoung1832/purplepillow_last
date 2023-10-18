import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class TitleViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var studionum: UITextView!
    @IBOutlet weak var PostcollectionView: UICollectionView!
    
    @IBOutlet weak var DefaultFlowBtn: UIButton!
    @IBOutlet weak var Default2FlowBtn: UIButton!
    
    @IBOutlet weak var view2: UIView!
    
    fileprivate var posts: [Post] = []
    fileprivate var currentUserProfile: UserProfile?
    var db: Firestore!
    var auth: Auth!
    var storage: Storage!
    var userProfileListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImg.layer.cornerRadius = 10 // 원하는 값으로 설정
        backImg.layer.shadowColor = UIColor.black.cgColor
        backImg.layer.shadowOpacity = 0.5 // 그림자 투명도 (0.0 ~ 1.0)
        backImg.layer.shadowOffset = CGSize(width: 0, height: 2) // 그림자 위치 (가로, 세로)
        backImg.layer.shadowRadius = 4 // 그림자 반경
        
        setupUI()
        setupCollectionView()
        setupFirebase()
        
        let post1 = Post(image: UIImage(named: "Ex1"), text: "첫 번째 게시글 내용", timestamp: "2023-08-09")
        let post2 = Post(image: UIImage(named: "Ex1"), text: "두 번째 게시글 내용", timestamp: "2023-08-10")
        let post3 = Post(image: UIImage(named: "Ex1"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post4 = Post(image: UIImage(named: "Ex1"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        let post5 = Post(image: UIImage(named: "Ex1"), text: "세 번째 게시글 내용", timestamp: "2023-08-11")
        
          
        // Add these posts to the 'posts' array
        posts = [post1, post2, post3,post4,post5]
        
        // Set the collection view layout to the default layout
        PostcollectionView.collectionViewLayout = createCompositionalLayoutForTwoByTwo()
    }
    
    func setupUI() {
        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.height / 2
        ProfileImageView.layer.borderWidth = 1
        ProfileImageView.clipsToBounds = true
        ProfileImageView.layer.borderColor = UIColor.blue.cgColor
    }
    
    func setupCollectionView() {
        PostcollectionView.dataSource = self
        PostcollectionView.delegate = self
        
        PostcollectionView.register(UINib(nibName: "PostCell", bundle: nil), forCellWithReuseIdentifier: "PostCell")
        
        // Set the estimated item size for better cell sizing
        if let layout = PostcollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 167, height: 87)
        }
    }
    
    func setupFirebase() {
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
                    if let unwrappedData = document.data() {
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
    
    @IBAction func defaultFlowBtnTapped(_ sender: UIButton) {
        // Change the collection view layout to the default two-by-two layout
        PostcollectionView.collectionViewLayout = createCompositionalLayoutForTwoByTwo()
    }

    @IBAction func default2FlowBtnTapped(_ sender: UIButton) {
        // Change the collection view layout to the smaller cell size layout
        PostcollectionView.collectionViewLayout = createCompositionalLayoutForSmallerCells()
    }
}

extension TitleViewController {
    
    fileprivate func createCompositionalLayoutForTwoByTwo() -> UICollectionViewLayout {
        // This is the default two-by-two layout
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            // Set the vertical spacing between items to match the width (horizontal spacing)
            group.interItemSpacing = .fixed(10) // You can adjust the spacing as needed
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        }
        return layout
    }

    
    
    fileprivate func createCompositionalLayoutForSmallerCells() -> UICollectionViewLayout {
        // This layout is for smaller cells (350x150)
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)) // Set the height to 150
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Use a group with a single item to ensure each cell's width is the full width of the collection view
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)) // Set the height to 150
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        }
        return layout
    }
}

extension TitleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // PostCell 식별자로 셀을 로드
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath)

        // 데이터를 가져오거나 필요한 내용으로 셀을 업데이트합니다.
        let post1 = posts[indexPath.item]
        // PostCollectionViewCell의 서브뷰를 가져오거나 업데이트합니다.
        if let postCell = cell as? PostCollectionViewCell {
            postCell.post.image = post1.image
        }

        return cell
    }
}

extension TitleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.collectionViewLayout == createCompositionalLayoutForTwoByTwo() {
            return CGSize(width: 167, height: 87)
        } else if collectionView.collectionViewLayout == createCompositionalLayoutForSmallerCells() {
            return CGSize(width: 350, height: 150)
        } else {
            return CGSize(width: 167, height: 87) // Default size
        }
    }
}
