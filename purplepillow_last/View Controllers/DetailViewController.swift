import UIKit
import PanModal

class DetailViewController: UIViewController {


    @IBOutlet weak var timestampLabel: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UITextField!
    @IBOutlet weak var moreButton: UIBarButtonItem!

    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let post = post {
            imageView.image = post.image
            textLabel.text = post.text
            timestampLabel.text = post.timestamp
        }
    }

    @IBAction func onMorebuttonClicked(_ sender: UIBarButtonItem) {
            switch sender {
            case moreButton:
                let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(identifier: "MyTableVC") as! MyTableVC
                vc.modalPresentationStyle = .custom // 팝업 스타일 설정
                presentPanModal(vc)
            default:
                break
            }
        }
    }
