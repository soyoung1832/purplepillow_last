import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if collectionView == MainBanner {
             return mainBannerImages.count
         } else if collectionView == NewCollection {
             return newCollectionData.count
         } else if collectionView == PilloweezCollection {
             return pilloweezData.count
         } else {
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
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PilloweezCell", for: indexPath) as! PilloweezCollectionViewCell
             // 데이터를 VerticalCell에 연결 (데이터가 없으므로 빈 상태로 표시)
             return cell
         } else if collectionView == PilloweezCollection {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
             let userProfile = pilloweezData[indexPath.item]
             // UserProfile 데이터를 VerticalCell에 연결
             cell.configure(with: userProfile)
             return cell
         }
         return UICollectionViewCell()
     }
     
    
    // Firestore 데이터베이스 참조 생성
    let db = Firestore.firestore()

    @IBOutlet weak var MainBanner: UICollectionView!
    @IBOutlet weak var NewCollection: UICollectionView!
    @IBOutlet weak var PilloweezCollection: UICollectionView!

    var mainBannerImages: [UIImage] = [] // 기본 이미지 배열
    var newCollectionData: [UIImage] = [] // 빈 데이터 배열
    var pilloweezData: [UserProfile] = [] // Firestore에서 가져온 UserProfile 데이터

    override func viewDidLoad() {
        super.viewDidLoad()

        // Firestore에서 UserProfile 데이터 가져오기
        fetchUserProfiles()

        // MainBanner에 기본 이미지 추가
        mainBannerImages = [UIImage(named: "Ex1")!, UIImage(named: "Ex1")!, UIImage(named: "Ex1")!]
        
        newCollectionData = [UIImage(named: "Ex1")!, UIImage(named: "Ex1")!, UIImage(named: "Ex1")!]

        MainBanner.dataSource = self
        MainBanner.delegate = self
        NewCollection.dataSource = self
        NewCollection.delegate = self
        PilloweezCollection.dataSource = self
        PilloweezCollection.delegate = self

        // "VerticalCell" 셀 클래스를 등록
        NewCollection.register(UINib(nibName: "PilloweezCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PilloweezCell")
        // "PilloweezCell" 셀 등록
        PilloweezCollection.register(UINib(nibName: "VerticalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VerticalCell")
        
        MainBanner.register(UINib(nibName: "PilloweezCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PilloweezCell")
    }

    // Firestore에서 UserProfile 데이터를 가져오는 메서드
    func fetchUserProfiles() {
        db.collection("userProfiles").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if let data = document.data() as? [String: Any] {
                        let userProfile = UserProfile(data: data)
                        self.pilloweezData.append(userProfile)
                    }
                }
                // 데이터를 가져온 후, PilloweezCollection 컬렉션 뷰를 리로드
                self.PilloweezCollection.reloadData()
            }
        }
    }

    // "VerticalCell" 셀의 크기를 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == NewCollection {
            // NewCollection에서 사용할 셀 크기를 반환 (130, 200)
            return CGSize(width: collectionView.bounds.width, height: 200)
        } else if collectionView == PilloweezCollection {
            // PilloweezCollection에서 사용할 셀 크기를 반환 (컬렉션 뷰의 너비, 150)
            return CGSize(width: 130, height: 200)
        } else if collectionView == MainBanner {
            // MainBanner에서 사용할 셀 크기를 반환 (컬렉션 뷰의 너비, 200)
            return CGSize(width: collectionView.bounds.width, height: 200)
        }
        // 기본 크기를 반환하거나, 다른 컬렉션 뷰가 있는 경우에 대한 처리를 추가할 수 있습니다.
        return CGSize(width: 50, height: 50) // 기본 크기
    }
}
