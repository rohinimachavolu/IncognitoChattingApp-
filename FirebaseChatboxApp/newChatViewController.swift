import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class newChatViewController: UIViewController {


    @IBOutlet weak var chatid: UILabel!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var roomname: UITextField!
    
    var datePicker: UIDatePicker! // Date picker for selecting time

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Generate a new 4-character random chatid and set it to the chatid label
        let newChatID = generateRandomChatID()
        chatid.text =  newChatID // Display the randomly generated chatid on the label
        
        // Set up the date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime // Allow both date and time selection
        datePicker.preferredDatePickerStyle = .wheels // Set wheel style for picker
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        
        // set up chat id
        setUpChatIdLabel()
        
        // Set the date picker as the input view for the time text field
        time.inputView = datePicker
        
        // Add a toolbar with a Done button for the time picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        time.inputAccessoryView = toolbar
    }

    // Generate a 4-character random chatid from UUID
    func generateRandomChatID() -> String {
        return UUID().uuidString.prefix(4).lowercased() // Take the first 4 characters of UUID and convert to lowercase
    }

    // Update the time text field when the date picker value changes
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        time.text = formatter.string(from: datePicker.date)
    }

    // Dismiss the keyboard when Done button is pressed
    @objc func donePressed() {
        time.resignFirstResponder()
    }
    
    // Action when creating a new room
    @IBAction func createroom(_ sender: Any) {
        let chatID = chatid.text ?? ""
        let roomName = roomname.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = ""

        if roomName.isEmpty {
            showAlert(message: "Room name cannot be empty.")
            return
        }

        let selectedDate = datePicker.date
        let currentDate = Date()
        
        if selectedDate < currentDate {
            showAlert(message: "Selected time cannot be earlier than the current time.")
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        let formattedTime = formatter.string(from: selectedDate)

        insertToFirestore(chatid: chatID, roomname: roomName, time: formattedTime, descriptions: description)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHome"), object: nil, userInfo: nil)
    }


    
    // MARK: - Firestore Data Insertion

    // Insert chat data into Firestore
    func insertToFirestore(chatid: String, roomname: String, time: String, descriptions: String) {
        let db = Firestore.firestore()
        let movieCollection = db.collection("teams")
        
        // Create a new Chat instance
        let matrix = customChat(chatid: chatid, roomname: roomname, time: time, descriptions: descriptions)
        
        // Attempt to add the chat data to Firestore
        do {
//            try movieCollection.addDocument(from: matrix) { (err) in
            try movieCollection.document(chatid).setData(from: matrix) { (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                    // Show error message if insertion fails
                    self.showAlert(message: "Error adding chat room: \(err.localizedDescription)")
                } else {
                    print("Successfully created chat room")
                    // Show success message after successful insertion
                    self.showAlertAndPopUp(message: "Chat room created successfully!")
                }
            }
        } catch let error {
            print("Error writing document to Firestore: \(error)")
            // Show error message if there is an exception
            self.showAlert(message: "Error writing document to Firestore: \(error.localizedDescription)")
        }
    }

    // Display an alert with a message
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlertAndPopUp(message: String) {
        let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    private func setUpChatIdLabel(){
        chatid.textColor = UIColor.lightGray
        chatid.textAlignment = .center
        
        chatid.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chatid)
        
        NSLayoutConstraint.activate([
            chatid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            chatid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chatid.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
