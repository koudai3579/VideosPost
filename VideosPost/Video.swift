import Foundation
import Firebase

class Video {
    
    let uid: String
    var tittle: String
    var videoUrl:String
    var thumbnailImageUrl:String
    var lastMessageAt:Timestamp
    
    init(dic: [String: Any]) {
        self.uid = dic["uid"] as? String ?? ""
        self.tittle = dic["tittle"] as? String ?? ""
        self.videoUrl = dic["videoUrl"] as? String ?? ""
        self.thumbnailImageUrl = dic["thumbnailImageUrl"] as? String ?? ""
        self.lastMessageAt = dic["lastMessageAt"] as? Timestamp ?? Timestamp()
    }
}
