import UIKit

class TitleViewController: UIViewController {

    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UILabel!
    @IBOutlet weak var BioTextField: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.height / 2
        ProfileImageView.layer.borderWidth = 1
        ProfileImageView.clipsToBounds = true
        ProfileImageView.layer.borderColor = UIColor.blue.cgColor

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        collectionView.dataSource = self
        collectionView.delegate = self

        // 임시로 데이터 생성하여 추가
        let post1 = Post(image: UIImage(systemName: "house")!, text: "첫 번째 게시글 내용", timestamp: "2023-08-09")
        let post2 = Post(image: UIImage(systemName: "sparkle")!, text: "두 번째 게시글 내용", timestamp: "2023-08-10")
        let post3 = Post(image: UIImage(systemName: "moon")!, text: "세 번째 게시글 내용", timestamp: "2023-08-11")

        posts = [post1, post2, post3]
    }
}

extension TitleViewController {

    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16) // Add spacing to the right of each item

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(16) // Set interItemSpacing to 16

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
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


