import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class TitleViewController: UIViewController, UICollectionViewDelegate {
    
    var userProfile: UserProfile?
        
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var unfriendButton: UIButton!
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var studionum: UITextView!
    @IBOutlet weak var PostcollectionView: UICollectionView!
    
    @IBOutlet weak var DefaultFlowBtn: UIButton!
    @IBOutlet weak var Default2FlowBtn: UIButton!
    
    
    @IBOutlet weak var pilloweezCount: UILabel!
    
    var posts: [userPost] = []
    var currentUserProfile: UserProfile?
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
        loadUserPosts()
        
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
        PostcollectionView.register(UINib(nibName: "Post2Cell", bundle: nil),forCellWithReuseIdentifier: "Post2Cell")
        
        // Set the estimated item size for better cell sizing
        if let layout = PostcollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 167, height: 87)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post1 = posts[indexPath.item]
        
        // DetailViewController를 생성합니다.
        if let detailViewController = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            // 선택한 게시물을 DetailViewController에 전달합니다.
            detailViewController.post1 = post1
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }

    
    func setupFirebase() {
        db = Firestore.firestore()
        auth = Auth.auth()
        storage = Storage.storage()
        
        loadCurrentUserProfile()
    }
    
    
      func loadUserPosts() {
          if let uid = auth.currentUser?.uid {
              let postsRef = db.collection("posts").document(uid).collection("posts")
              postsRef.getDocuments { (querySnapshot, error) in
                  if let error = error {
                      print("Error fetching posts: \(error.localizedDescription)")
                      return
                  }

                  guard let documents = querySnapshot?.documents else {
                      print("No documents found")
                      return
                  }

                  self.posts = documents.compactMap { document in
                      return userPost(data: document.data())
                  }

                  // 게시물 데이터를 가져온 후 콜렉션 뷰를 리로드
                  self.PostcollectionView.reloadData()
              }
          }
      }

    func loadImage(for cell: PostCollectionViewCell, at indexPath: IndexPath) {
        let post = posts[indexPath.item]
        if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.post.image = image
                    }
                }
            }.resume()
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath)

        let post = posts[indexPath.item]
        
        if let postCell = cell as? PostCollectionViewCell {
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error downloading image: \(error)")
                        return
                    }

                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            postCell.post.image = image // 이미지 업데이트
                            // 다른 UI 업데이트 작업을 수행할 수 있습니다.
                        }
                    }
                }.resume()
            }
        }

        return cell
    }

}

extension TitleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.collectionViewLayout == createCompositionalLayoutForTwoByTwo() {
            return CGSize(width: 200 , height: 150)
        } else if collectionView.collectionViewLayout == createCompositionalLayoutForSmallerCells() {
            return CGSize(width: 350, height: 150)
        } else {
            return CGSize(width: 300, height: 150) // Default size
        }
    }
}



