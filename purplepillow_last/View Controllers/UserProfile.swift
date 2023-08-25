//
//  UserProfile.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/24.
//

struct UserProfile {
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
