import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatListViewController: UIViewController,CustomBubbleViewDataSource,LynnBubbleViewDelegate {

    var chatid: String?
    var roomname: String?
    
    @IBOutlet weak var tbBubbleDemo: CustomBubbleTableView!
    @IBOutlet weak var roomnamestring: UILabel!
    
    var messages: [customMsg] = [] 
    @IBOutlet weak var sendmessagetext: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbBubbleDemo.bubbleDelegate = self
        tbBubbleDemo.bubbleDataSource = self
        
        
        // Display the roomname in the label
        if let roomname = roomname {
            roomnamestring.text = "Room Name: " + roomname
        }

        // Print chatid for debugging purposes
        if let chatid = chatid {
            print("ChatID: \(chatid)")
            loadMessages()
        }

        // Do any additional setup after loading the view.
    }

    // MARK: - TableView DataSource Methods

  /*  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as! ChatListTableViewCell
        let message = messages[indexPath.row]
        cell.usernameTxt.text = message.username
        cell.timeTxt.text =   message.message + " " + formatTimestamp(message.timestamp)
      //  cell.messageTxt.text = message.message // 显示消息内容
        return cell
    }*/
    
    var arrChatTest:Array<customBubbleData> = []
    func bubbleTableView(dataAt index: Int, bubbleTableView: CustomBubbleTableView) -> customBubbleData {
        return self.arrChatTest[index]
    }
    
    func bubbleTableView(numberOfRows bubbleTableView: CustomBubbleTableView) -> Int {
        return self.arrChatTest.count
    }
    
    // MARK: - Send Message Action
    @IBAction func sentTapped(_ sender: Any) {
        guard let messageText = sendmessagetext.text, !messageText.isEmpty else {
            return // 如果输入框为空，则不执行任何操作
        }
        
        guard let chatid = chatid else { return }

        // 获取当前时间戳
        let timestamp = Timestamp(date: Date())

        // 获取当前用户名
        let username = loginViewController.name // Assuming loginViewController.name gives the current user name

        // 创建一个 Message 对象
        let message = customMsg(username: username, message: messageText, timestamp: timestamp)

        // Firestore 操作
        let db = Firestore.firestore()
        let docRef = db.collection("teams").document(chatid)

        // Try to update the document if it exists, or create a new one
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking document: \(error)")
            } else {
                if let document = document, document.exists {
                    // If document exists, update messages array
                    docRef.updateData([
                        "messages": FieldValue.arrayUnion([[
                            "username": message.username,
                            "message": message.message,
                            "timestamp": message.timestamp
                        ]])
                    ]) { error in
                        if let error = error {
                            print("Error sending message: \(error)")
                        } else {
                            print("Message sent successfully")
                            self.sendmessagetext.text = "" // Clear the input field
                            
                            // Create LynnUserData for the sent message
                            let userData = CustomUserData(userUniqueId: message.username)

                            // Create LynnBubbleData and add it to arrChatTest
                            let bubbleData = customBubbleData(userData: userData, dataOwner: .me, message: message.message, messageDate: timestamp.dateValue())
                            self.arrChatTest.append(bubbleData)

                            // Refresh the bubbleTableView
                            self.tbBubbleDemo.reloadData()
                        }
                    }
                } else {
                    // If document does not exist, create a new document and add message
                    docRef.setData([
                        "messages": [
                            [
                                "username": message.username,
                                "message": message.message,
                                "timestamp": message.timestamp
                            ]
                        ]
                    ]) { error in
                        if let error = error {
                            print("Error creating document: \(error)")
                        } else {
                            print("New chat room created and message added")
                            self.sendmessagetext.text = "" // Clear the input field
                            
                            // Create LynnUserData for the sent message
                            let userData = CustomUserData(userUniqueId: message.username)

                            // Create LynnBubbleData and add it to arrChatTest
                            let bubbleData = customBubbleData(userData: userData, dataOwner: .none, message: message.message, messageDate: timestamp.dateValue())
                            self.arrChatTest.append(bubbleData)

                     //       // Refresh the bubbleTableView
                            self.tbBubbleDemo.reloadData()
                        }
                    }
                }
            }
        }
    }

    
    // MARK: - Load Messages from Firebase

    func loadMessages() {
        guard let chatid = chatid else { return }

        // Firestore 监听消息的集合
        let db = Firestore.firestore()
        db.collection("teams").document(chatid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading messages: \(error)")
                    return
                }
                
                guard let snapshot = snapshot, let data = snapshot.data() else { return }

                // 清空消息数组
                self?.messages.removeAll()
                self?.arrChatTest.removeAll() // Clear the bubble data array

                // 获取消息数组
                if let messageArray = data["messages"] as? [[String: Any]] {
                    for messageData in messageArray {
                        if let username = messageData["username"] as? String,
                           let message = messageData["message"] as? String,
                           let timestamp = messageData["timestamp"] as? Timestamp {
                            let message = customMsg(username: username, message: message, timestamp: timestamp)
                            self?.messages.append(message)

                            // Create LynnUserData object
                            let userData = CustomUserData(userUniqueId: message.username) // Assuming the username is a unique ID

                            // Assign BubbleDataType as .none (or another appropriate value)
                            let bubbleData = customBubbleData(userData: userData, dataOwner: .none, message: message.message, messageDate: timestamp.dateValue())

                            // Append the new bubble data to the array
                            self?.arrChatTest.append(bubbleData)
                        }
                    }
                }

                // 刷新 bubbleTableView
                self?.tbBubbleDemo.reloadData()
            }
    }

    // MARK: - Helper Methods

    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}

