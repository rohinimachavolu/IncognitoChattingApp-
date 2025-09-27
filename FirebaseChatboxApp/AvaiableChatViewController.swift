import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class AvaiableChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // Observable properties with Combine
    @Published var roomidstring: [String] = []
    @Published var roomnamestring: [String] = []
    @Published var roomtimestring: [String] = []  // Array to store chat timestamps
    @Published var filteredRoomIds: [String] = []  // Filtered room IDs for search
    @Published var filteredRoomNames: [String] = []  // Filtered room names for search
    @Published var filteredRoomTimes: [String] = []  // Filtered room times for search

    var cancellables = Set<AnyCancellable>()  // Store any cancellables for Combine
    var timer: Timer?  // To trigger periodic checks for expired chats

    @IBOutlet weak var searchbox: UISearchBar!
    @IBOutlet weak var theTable: UITableView!  // UITableView outlet

    // Selected room data (to pass in segue)
    var selectedChatId: String?
    var selectedRoomName: String?

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRoomIds.count  // Use filtered array
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvaiableChatTableViewCell", for: indexPath) as! AvaiableChatTableViewCell
//        cell.roomNameTxt.text = "Name: " + filteredRoomNames[indexPath.row] + " - " + filteredRoomTimes[indexPath.row]
        cell.roomNameTxt.text = "Name: " + filteredRoomNames[indexPath.row]
        cell.roomidText.text = "ID: " + filteredRoomIds[indexPath.row]
        if let (date, time) = splitDateTime(dateTimeString: filteredRoomTimes[indexPath.row]) {
            cell.dateLabel.text = "End at " + time
            cell.timeLabel.text = date
        }
        return cell
    }

    // click event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatId = filteredRoomIds[indexPath.row]
        selectedRoomName = filteredRoomNames[indexPath.row]
//        self.performSegue(withIdentifier: "showchat", sender: nil)
                
        var channel = Channel(name: selectedRoomName ?? "Default Room Name")
        channel.id = selectedChatId
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in.")
            return
        }
        let viewController = ChatViewController(user: currentUser, channel: channel)
        viewController.chatEndTime = filteredRoomTimes[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
        
//        let testVC = TestController()
//        self.navigationController?.pushViewController(testVC, animated: true)
    }
    @objc func refreshHome(notification: NSNotification){
          loadData()
      }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshHome(notification:)), name: NSNotification.Name(rawValue: "refreshHome"), object: nil)
        
        // Ensure Firebase is initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Set up searchbox delegate
        searchbox.delegate = self
        searchbox.placeholder = "Currently Unavailable"
        searchbox.isUserInteractionEnabled = false
        searchbox.alpha = 0.5


        // Bind observable properties to UI changes
        bindData()

        // Load data from Firestore
        loadData()

      //  checkExpiredChatsNow()
        // Check for expired chats immediately after data load
//        checkExpiredChats()

        // Start the timer to check every minute for expired chats
        startTimer()

        // Observe when the app comes back to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Load Data from Firestore
    func loadData() {
        let db = Firestore.firestore()
        let movieCollection = db.collection("teams")

        movieCollection.getDocuments() { [weak self] (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self?.showErrorAlert(message: "Failed to load data.")
            } else {
                // Clear existing data before adding new data
                self?.roomidstring.removeAll()
                self?.roomnamestring.removeAll()
                self?.roomtimestring.removeAll()

                // Current time
                let currentTime = Date()

                // Loop through the documents and map to model
                for document in result!.documents {
                    let conversionResult = Result {
                        try document.data(as: customChat.self)
                    }

                    switch conversionResult {
                    case .success(let chat):
                        // Convert the time string to Date using DateFormatter
                        if let chatTime = self?.convertStringToDate(chat.time) {
                            // Add valid chats to the list
                            self?.roomidstring.append(chat.chatid)
                            self?.roomnamestring.append(chat.roomname)
                            self?.roomtimestring.append(chat.time)  // Store the timestamp
                            
                        }
                    case .failure(let error):
                        print("Error decoding chat: \(error)")
                    }
                }

                // Initially set the filtered data to all data
                self?.filteredRoomIds = self?.roomidstring ?? []
                self?.filteredRoomNames = self?.roomnamestring ?? []
                self?.filteredRoomTimes = self?.roomtimestring ?? []  // Set filteredRoomTimes as well
            }
        }
    }

    // MARK: - Convert String to Date
    func convertStringToDate(_ timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm" // Format for "Nov 23, 2024 at 18:49"
        return dateFormatter.date(from: timeString)
    }

    // MARK: - Start Timer to Check Expired Chats
    func startTimer() {
        // Timer will fire every 60 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkExpiredChats), userInfo: nil, repeats: true)
    }
    
    func checkExpiredChatsNow() {
        let currentTime = Date()
        var expiredIndices: [Int] = []


      //  print("Current time: \(currentTime)")


        for (index, chatTimeString) in filteredRoomTimes.enumerated() {
            if let chatTime = convertStringToDate(chatTimeString) {
       
           //     print("Chat time for room at index \(index): \(chatTime)")

              
                if chatTime < currentTime {
               //     print("Chat at index \(index) is expired.")
                    expiredIndices.append(index)
                }
            }
        }


        for index in expiredIndices.reversed() {  // Reverse to avoid index shifting issues
            print("Removing expired chat at index: \(index)")
            filteredRoomNames.remove(at: index)
            deleteChatRoom(roomId: filteredRoomIds[index])
            filteredRoomIds.remove(at: index)
            filteredRoomTimes.remove(at: index)
        }

        theTable.reloadData()
    }


    // MARK: - Check for Expired Chats
    @objc func checkExpiredChats() {
        let currentTime = Date()
        var expiredIndices: [Int] = []

        // print curr time
       // print("Current time: \(currentTime)")

        //  iterate filteredRoomTimes，check time of each room
        for (index, chatTimeString) in filteredRoomTimes.enumerated() {
            if let chatTime = convertStringToDate(chatTimeString) {
                // print chat room time
            //    print("Chat time for room at index \(index): \(chatTime)")

                // compare chat room time and actual time
                if chatTime < currentTime {
             //       print("Chat at index \(index) is expired.")
                    expiredIndices.append(index)
                }
            }
        }

        // delete chat rooms
        for index in expiredIndices.reversed() {  // Reverse to avoid index shifting issues
            print("Removing expired chat at index: \(index)")
            filteredRoomNames.remove(at: index)
            deleteChatRoom(roomId: filteredRoomIds[index])
            filteredRoomIds.remove(at: index)
            filteredRoomTimes.remove(at: index)
        }

        theTable.reloadData()
    }
    
    func deleteChatRoom(roomId: String) {
        let db = Firestore.firestore()
        
        print("Attempting to delete chat room with roomId: \(roomId)")
        
        // delete room from firestore
        db.collection("teams").document(roomId).delete { [weak self] error in
            if let error = error {
                print("Error deleting chat room \(roomId): \(error.localizedDescription)")
            } else {
                print("Successfully deleted chat room \(roomId) from Firestore")
            }
        }
    }




    // MARK: - Data Binding with Combine
    func bindData() {
        // Subscribe to changes in filteredRoomIds, filteredRoomNames, and filteredRoomTimes
        $filteredRoomIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.theTable.reloadData()
            }
            .store(in: &cancellables)

        $filteredRoomNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.theTable.reloadData()
            }
            .store(in: &cancellables)

        $filteredRoomTimes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.theTable.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - UISearchBarDelegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filtering logic based on search text
        if searchText.isEmpty {
            filteredRoomIds = roomidstring
            filteredRoomNames = roomnamestring
            filteredRoomTimes = roomtimestring  // Reset filtered times as well
        } else {
            filteredRoomIds = roomidstring.filter { $0.lowercased().contains(searchText.lowercased()) }
            filteredRoomNames = roomnamestring.filter { $0.lowercased().contains(searchText.lowercased()) }
            filteredRoomTimes = roomtimestring.filter { $0.lowercased().contains(searchText.lowercased()) } // Filter times as well
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredRoomIds = roomidstring
        filteredRoomNames = roomnamestring
        filteredRoomTimes = roomtimestring  // Reset filtered times as well
        searchBar.resignFirstResponder()
    }

    // MARK: - Error Handling
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showchat" {
            if let destinationVC = segue.destination as? ChatListViewController {
                destinationVC.chatid = selectedChatId
                destinationVC.roomname = selectedRoomName
            }
        }
    }

    // MARK: - App Lifecycle Handling
    @objc func appDidBecomeActive() {
        // Check for expired chats when the app comes back to the foreground
        checkExpiredChats()
    }

    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func splitDateTime(dateTimeString: String) -> (date: String, time: String)? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")


        guard let date = inputFormatter.date(from: dateTimeString) else {
            print("Error parsing date string")
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: date)

        return (date: dateString, time: timeString)
    }
}
