import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var post: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
        post.layer.cornerRadius = 10
        post.layer.masksToBounds = true
    }
    
    func addShadow() {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
}
