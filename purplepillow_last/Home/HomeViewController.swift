import UIKit
import Firebase
import FirebaseFirestore


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func didTapVisitButton(_ userProfile: UserProfile) {
        // 화면 전환 및 데이터 전달
        if let titleViewController = storyboard?.instantiateViewController(withIdentifier: "UserTitleViewController") as? UserTitleViewController {
            titleViewController.visitedUserID = userProfile.uid
            navigationController?.pushViewController(titleViewController, animated: true)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == MainBanner {
            return mainBannerImages.count
        } else if collectionView == NewCollection {
            return newCollectionData.count
        } else if collectionView == PilloweezCollection {
            // 여기서 5개의 셀만 보이도록 설정
            return min(pilloweezData.count, 5)
        } else if collectionView == RecentCollection{
            return recentCollectionData.count
        }else {
            return 0
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == MainBanner {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PilloweezCell", for: indexPath) as! PilloweezCollectionViewCell
            if let mainImageView = cell.Main {
                mainImageView.image = mainBannerImages[indexPath.item]
            }
            return cell
        } else if collectionView == NewCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "verticalDefaultCell", for: indexPath) as! VerticalDefaultCollectionViewCell
            cell.itemImg.image = newCollectionData[indexPath.item]
            return cell
        } else if collectionView == PilloweezCollection {
            if indexPath.item < min(pilloweezData.count, 5) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
                let userProfile = pilloweezData[indexPath.item]
                cell.configure(with: userProfile)
                cell.visitButtonAction = { [weak self] uid in
                      // Handle the Visit button action
                      self?.didTapVisitButton(userProfile) // userProfile은 사용자 프로필 데이터입니다.
                  }
                  return cell
            }
        }else if collectionView == RecentCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PilloweezCell", for: indexPath) as! PilloweezCollectionViewCell
            let userPost = recentCollectionData[indexPath.item]
            cell.configure(with: userPost)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    // Firestore 데이터베이스 참조 생성
    let db = Firestore.firestore()
    let auth = Auth.auth()
    

    
    func refreshData() {
        
        fetchUserProfiles()
    
    }
    
    @IBAction func didClickRefreshBtn(_ sender: Any) {
        
        refreshData()
    }
    
    
    
    @IBOutlet weak var MainBanner: UICollectionView!
    @IBOutlet weak var NewCollection: UICollectionView!
    @IBOutlet weak var PilloweezCollection: UICollectionView!
    @IBOutlet weak var RecentCollection: UICollectionView!
    
    var mainBannerImages: [UIImage] = []// 기본 이미지 배열
    var recentCollectionData: [userPost] = []
    var newCollectionData: [UIImage] = [] // 빈 데이터 배열
    var pilloweezData: [UserProfile] = [] // Firestore에서 가져온 UserProfile 데이터
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchUserProfiles()

        
        let logoImageView = UIImageView(image: UIImage(named: "PurplePillow"))
        logoImageView.contentMode = .scaleAspectFit // 이미지가 크기에 맞게 비율 유지하도록 설정
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoImageView.image?.size.width ?? 0, height: logoImageView.image?.size.height ?? 0)
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.7) // 이미지 크기를 0.5배로 축소
        navigationItem.titleView = logoImageView
        
        
     
        
        // MainBanner에 기본 이미지 추가
        mainBannerImages = [
                   UIImage(named: "Ex1")!,
                   UIImage(named: "Ex1")!,
                   UIImage(named: "Ex1")!
               ]
        
        fetchUserPost()
        
        newCollectionData = [UIImage(named: "베스트 샷 1")!, UIImage(named: "베스트 샷 1")!, UIImage(named: "베스트 샷 1")!]
        
        MainBanner.dataSource = self
        MainBanner.delegate = self
        NewCollection.dataSource = self
        NewCollection.delegate = self
        PilloweezCollection.dataSource = self
        PilloweezCollection.delegate = self
        RecentCollection.dataSource=self
        RecentCollection.delegate=self
        
        RecentCollection.allowsSelection = true
        
        // "VerticalCell" 셀 클래스를 등록
        NewCollection.register(UINib(nibName: "VerticalDefaultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "verticalDefaultCell")
        // "PilloweezCell" 셀 등록
        PilloweezCollection.register(UINib(nibName: "VerticalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VerticalCell")
        
        MainBanner.register(UINib(nibName: "PilloweezCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PilloweezCell")
        
        RecentCollection.register(UINib(nibName: "PilloweezCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PilloweezCell")
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == RecentCollection {
            if let uid = auth.currentUser?.uid {
            let post1 = recentCollectionData[indexPath.row] // item 대신 row 사용
            
            var storyboardName: String
            var viewControllerIdentifier: String
            
            if post1.uid == uid {
                storyboardName = "Mypage"
                viewControllerIdentifier = "DetailViewController"
            } else {
                storyboardName = "Home"
                viewControllerIdentifier = "UserDetailViewController"
            }
            
            if let detailViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: viewControllerIdentifier) as? UIViewController {
                if let detailViewController = detailViewController as? DetailViewController {
                    // 선택한 게시물을 DetailViewController에 전달합니다.
                    detailViewController.post1 = post1
                } else if let detailViewController = detailViewController as? UserDetailViewController {
                    // 선택한 게시물을 UserDetailViewController에 전달합니다.
                    detailViewController.post1 = post1
                }
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
        }
    }

    
    // "userPost"에서 데이터를 가져와서 RecentCollection 업데이트
    func fetchUserPost() {
        db.collection("userPost").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if let data = document.data() as? [String: Any] {
                        let userPost = userPost(data: data)
                        self.recentCollectionData.append(userPost)
                    }
                }
                // 데이터를 가져온 후, PilloweezCollection 컬렉션 뷰를 리로드
                self.RecentCollection.reloadData()
            }
        }
    }
    
    
    func fetchUserProfiles() {
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("userProfiles").document(uid).getDocument { [weak self] (documentSnapshot, error) in
                guard let self = self, let document = documentSnapshot, document.exists else {
                    if let error = error {
                        print("Error fetching user profile: \(error)")
                    }
                    return
                }

                let data = document.data() as? [String: Any] ?? [:]

                if let pilloweezUIDs = data["pilloweez"] as? [String] {
                    for uid2 in pilloweezUIDs {
                        self.fetchUserProfile(for: uid2)
                    }
                }
            }
        }
    }


    
    
    func fetchUserProfile(for uid2: String) {
        db.collection("userProfiles").document(uid2).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self, let document = documentSnapshot, document.exists else {
                if let error = error {
                    print("Error fetching user profile for \(uid2): \(error)")
                }
                return
            }

            let data = document.data() as? [String: Any] ?? [:]
            let userProfile = UserProfile(data: data)

            // userProfile을 데이터 소스에 추가
            self.pilloweezData.append(userProfile)

            // 데이터를 가져온 후, PilloweezCollection 컬렉션 뷰를 리로드
            DispatchQueue.main.async {
                self.PilloweezCollection.reloadData()
            }
        }
    }


    
    // "VerticalCell" 셀의 크기를 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == NewCollection {
            // NewCollection에서 사용할 셀 크기를 반환 (130, 200)
            return CGSize(width: 130, height: 200)
        } else if collectionView == PilloweezCollection {
            // PilloweezCollection에서 사용할 셀 크기를 반환 (컬렉션 뷰의 너비, 150)
            return CGSize(width: 130, height: 200)
        } else if collectionView == MainBanner {
            // MainBanner에서 사용할 셀 크기를 반환 (컬렉션 뷰의 너비, 200)
            return CGSize(width:300, height:200)
        }
        else if collectionView == RecentCollection {
            // MainBanner에서 사용할 셀 크기를 반환 (컬렉션 뷰의 너비, 200)
            return CGSize(width: 300, height: 150)
        }
        // 기본 크기를 반환하거나, 다른 컬렉션 뷰가 있는 경우에 대한 처리를 추가할 수 있습니다.
        return CGSize(width: 50, height: 50) // 기본 크기
    }
    
    

}
