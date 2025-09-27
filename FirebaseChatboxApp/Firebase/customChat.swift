import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// MARK: - Chat Model

public struct customChat: Codable {
    @DocumentID var documentID: String?
    var chatid: String
    var roomname: String
    var time: String
    var descriptions: String
    
    init(documentID: String? = nil, chatid: String, roomname: String, time: String, descriptions: String) {
        self.documentID = documentID
        self.chatid = chatid
        self.roomname = roomname
        self.time = time
        self.descriptions = descriptions
    }
}


// MARK: - Message Model

public struct customMsg: Codable {
    @DocumentID var documentID: String?
    var username: String
    var message: String
    var timestamp: Timestamp
    
    init(documentID: String? = nil, username: String, message: String, timestamp: Timestamp) {
        self.documentID = documentID
        self.username = username
        self.message = message
        self.timestamp = timestamp
    }
}
