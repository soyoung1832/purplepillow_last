import UIKit
import SwiftUI

class StudioViewController: UIViewController {
    
    
    override func viewDidLoad() {
            super.viewDidLoad()

            let vc = UIHostingController(rootView: ContentView())
            addChild(vc)
            vc.view.frame = self.view.frame
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
    
}
