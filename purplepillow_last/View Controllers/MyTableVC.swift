//
//  MyTableVC.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/16.
//

import Foundation
import UIKit
import PanModal

class MyTableVC : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MyTableVC: PanModalPresentable{
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight{
        return.contentHeight(300)
    }
    
    var longFormHeight: PanModalHeight{
        return .maxHeightWithTopInset(100)
    }
    
    var anchorModalToLongForm: Bool{
        return true
    }
    
}
