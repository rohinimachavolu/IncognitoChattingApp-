import FirebaseFirestore

struct Channel {
  var id: String?
  let name: String

    // filed borrowed from custom chat
//    var chatid: String
//    var roomname: String
//    var time: String
//    var descriptions: String


  init(name: String) {
    id = nil
    self.name = name
  }

  init?(document: QueryDocumentSnapshot) {
    let data = document.data()

    guard let name = data["name"] as? String else {
      return nil
    }

    id = document.documentID
    self.name = name
  }
}

// MARK: - DatabaseRepresentation
extension Channel: DatabaseRepresentation {
  var representation: [String: Any] {
    var rep = ["name": name]

    if let id = id {
      rep["id"] = id
    }

    return rep
  }
}

// MARK: - Comparable
extension Channel: Comparable {
  static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }
}

// code borrow from cutomchat
extension Channel{
    init(documentID: String? = nil, chatid: String, roomname: String, time: String, descriptions: String) {
        id = chatid
        name = roomname
//        self.documentID = documentID
//        self.chatid = chatid
//        self.roomname = roomname
//        self.time = time
//        self.descriptions = descriptions
    }
}
