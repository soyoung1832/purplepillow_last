//
//  StudioViewController.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/29.
//

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
