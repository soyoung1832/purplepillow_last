//
//  PostsTableViewController.swift
//  purplepillow_last
//
//  Created by test on 2023/10/30.
//

import UIKit
import Firebase
import FirebaseStorage

class PostsTableViewController: UITableViewController {
    
    let auth = Auth.auth()
    
    var userPosts: [userPost] = []
    
    var userProfile: UserProfile?
    
    @objc func profileImageTapped(with userID: String) {
        if let visitedUserID = userProfile?.uid {
            // PostDetailTableViewCell 내에서 visitedUserID를 사용
            if let userTitleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTitleViewController") as? UserTitleViewController {
                userTitleViewController.visitedUserID = visitedUserID
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.window?.rootViewController?.present(userTitleViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "postDetailCell")
        fetchAllUserPosts()
    }
    
    func fetchAllUserPosts() {
        let db = Firestore.firestore()
        let userProfilesRef = db.collection("userPost")
        
        userProfilesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user profiles: \(error.localizedDescription)")
            } else {
                // Successful fetch
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let userPost = userPost(data: data)
                    self.userPosts.append(userPost)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postDetailCell", for: indexPath) as! PostDetailTableViewCell
        let userPost = userPosts[indexPath.row]
        cell.configure(with: userPost)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330.0 // 셀의 높이를 70 포인트로 설정
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let uid = auth.currentUser?.uid {
            let post1 = userPosts[indexPath.row] // item 대신 row 사용
            
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



