import Foundation
import UIKit

struct Post {
    var image: UIImage?
    var text: String?
    var timestamp: String?
}

public struct UserPost {
    
    let identifier: String
    let thumbnailImage: URL
    let postURL: URL // either video ur or full resolution phto
    let caption: String?
    let likeCount: [PostLikes]
    let createdDate: Date
}


struct PostLikes {
    
    let username: String
    let postIdentifier: String
    
}

struct UserCount{
    
    let pilloweez: Int
    let posts : Int
    
}

struct UserProfile {
    
    let counts = UserCount(pilloweez: 0, posts: 0)
    var imageUrl: String?
    var username: String?
    var bio: String?
    var uid: String?
    

    init(data: [String: Any]) {
        self.imageUrl = data["imageUrl"] as? String
        self.username = data["username"] as? String
        self.bio = data["bio"] as? String
        self.uid = data["uid"] as? String
    }
}
