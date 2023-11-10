import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class UserTitleViewController: UIViewController, UICollectionViewDelegate  {
    
    var userProfile: UserProfile?
    var visitedUserID: String?
 
        
    @IBOutlet weak var pilloweezButton: UIButton!
   
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var studionum: UITextView!
    @IBOutlet weak var PostcollectionView: UICollectionView!
    
    @IBOutlet weak var pilloweezCount: UILabel!
    @IBOutlet weak var DefaultFlowBtn: UIButton!
    @IBOutlet weak var Default2FlowBtn: UIButton!

          
    var posts: [userPost] = []
    var currentUserProfile: UserProfile?
    var db: Firestore!
    var auth: Auth!
    var storage: Storage!
    var userProfileListener: ListenerRegistration?
    
    
    @IBAction func didTapRequestBtn(_ sender: Any) {
        
        let userId = visitedUserID
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let followRequestsRef = db.collection("follow_requests")
        
        // 이미 팔로우 신청을 보낸 경우 중복으로 보내지 않도록 확인
        followRequestsRef
            .whereField("fromUserId", isEqualTo: currentUserUID)
            .whereField("toUserId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error checking duplicate follow request: \(error.localizedDescription)")
                } else if querySnapshot?.documents.isEmpty == true {
                    // 중복된 팔로우 신청이 없을 경우에만 새로운 팔로우 신청을 Firestore에 추가
                    let data: [String: Any] = [
                        "fromUserId": currentUserUID,
                        "toUserId": userId
                    ]
                    
                    followRequestsRef.addDocument(data: data) { error in
                        if let error = error {
                            print("Error sending follow request: \(error.localizedDescription)")
                        } else {
                            print("Follow request sent successfully.")
                            self.pilloweezButton.titleLabel?.text="요청됨"
                        }
                    }
                }
            }
        
        
    }
    
    
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
        loadCurrentUserProfile()
        
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
    
    func setupFirebase() {
        db = Firestore.firestore()
        auth = Auth.auth()
        storage = Storage.storage()
        
        loadCurrentUserProfile()
    }
    
    
      func loadUserPosts() {
          if let uid = visitedUserID{
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post1 = posts[indexPath.item]
        
        // DetailViewController를 생성합니다.
        if let detailViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "UserDetailViewController") as? UserDetailViewController {
            // 선택한 게시물을 DetailViewController에 전달합니다.
            detailViewController.post1 = post1
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func loadCurrentUserProfile() {
        if let uid = visitedUserID {
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

extension UserTitleViewController {
    
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

extension UserTitleViewController: UICollectionViewDataSource {
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

extension UserTitleViewController: UICollectionViewDelegateFlowLayout {
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

