//
//  MyTableVC.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/16.
//

import Foundation
import UIKit
import PanModal

class MyTableVC: UITableViewController,PanModalPresentable {
    var panScrollable: UIScrollView?
    
    
    struct CellData {
        var title: String
        var image: UIImage  // 이미지를 UIImage로 저장
    }

    let data = [CellData(title: "Delete", image: UIImage(named: "Group 770")!),
                CellData(title: "Edit", image: UIImage(named: "4084230-200 1")!)]

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath) as! MoreTableViewCell
        let cellData = data[indexPath.row]
        cell.BtnLabel.text = cellData.title
        cell.BtnImg.image = cellData.image  // 이미지 설정

        return cell
    }
}
