import Foundation
import Firebase

class Video {
    
    let docID: String
    var tittle: String
    var videoUrl:String
    var thumbnailImageUrl:String
    var date:Timestamp
    var playedCount:Int
    
    init(dic: [String: Any]) {
        self.docID = dic["docID"] as? String ?? ""
        self.tittle = dic["tittle"] as? String ?? ""
        self.videoUrl = dic["videoUrl"] as? String ?? ""
        self.thumbnailImageUrl = dic["thumbnailImageUrl"] as? String ?? ""
        self.date = dic["lastMessageAt"] as? Timestamp ?? Timestamp()
        self.playedCount = dic["playedCount"] as? Int ?? 0
    }
}
