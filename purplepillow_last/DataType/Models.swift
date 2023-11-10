import Foundation
import UIKit

struct Post {
    var image: UIImage?
    var text: String?
    var timestamp: String?
}


public struct User {
    
    var uid: String?
    var bio: String?
    var username: String?
    var email : String?
    var password : String?
    var imageUrl : String?
    
    init(data: [String: Any]) {
        self.imageUrl = data["imageUrl"] as? String
        self.username = data["username"] as? String
        self.bio = data["bio"] as? String
        self.uid = data["uid"] as? String
        self.password = data["password"] as? String
        self.email = data["email"] as? String
    }

    
}
public struct userPost {
    
    var explain: String?
    var imageUrl: String?
    var uid: String?
    var ownerId: String?
    var postId : String?
    var username : String?
    var profile : String?
    var timestamp: String?
    var likeCount: Int
    var likes : [String: Bool]
    
    
      init(data: [String: Any]) {
          self.explain = data["explain"] as? String
          self.imageUrl = data["imageUrl"] as? String
          self.uid = data["uid"] as? String
          self.ownerId = data["ownerId"] as? String
          self.postId = data["postId"] as? String
          self.username = data["username"] as? String
          self.profile = data["profile"] as? String
          self.timestamp = data["timestamp"] as? String
          self.likeCount = data["likeCount"] as? Int ??  0
          self.likes = data["pilloweez"] as? [String: Bool] ?? [:]
          
      }
    
}


public struct UserPost {

    var imageUrl: String?
    var timestamp: String?
    
    init(data: [String: Any]) {
        self.imageUrl = data["imageUrl"] as? String
        self.timestamp = data["timestamp"] as? String
    }
}


struct UserProfile {
    
    var lastname : String?
    var firstname : String?
    var fullname : String?
    var imageUrl: String?
    var username: String?
    var bio: String?
    var uid: String?
    var pilloweezCount : Int?
    var postCount : Int?
    var pilloweez: [String]
  
    init(data: [String: Any]) {
        self.lastname = data["lastname"] as? String
        self.firstname = data["firstname"] as? String
        self.fullname = data["fullname"] as? String
        self.imageUrl = data["imageUrl"] as? String
        self.username = data["username"] as? String
        self.bio = data["bio"] as? String
        self.uid = data["uid"] as? String
        self.pilloweezCount = data["pilloweezCount"] as? Int
        self.postCount = data["postCount"] as? Int 
        self.pilloweez = data["pilloweez"] as? [String] ?? []  }
}
