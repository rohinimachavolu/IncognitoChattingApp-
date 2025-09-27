import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class loginViewController: UIViewController {
    
    // A variable to store the currently logged-in user's name
    static var name: String = ""
    
    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var myname: UITextField!
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't like random profile? You can edit it later"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var imagelist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var namelist: [String] = [
        "ShadowHunter",
        "NightmareWizard",
        "MysticKnight",
        "ThunderFury",
        "DragonSlayer",
        "PhoenixRider",
        "SilverWolf",
        "DarkValkyrie",
        "ArcaneSorcerer",
        "StormChaser"
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bottomLabel)
        // force logout
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//        
        NSLayoutConstraint.activate([
            bottomLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Add tap gesture to dismiss keyboard when tapping anywhere on the screen
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture1)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        if let username = myname.text, !username.isEmpty {
            loginViewController.name = username
            
            if let user = Auth.auth().currentUser {
                print("User already logged in: \(user.uid)")
                self.performSegue(withIdentifier: "showmain", sender: self)
            } else {
                Auth.auth().signInAnonymously { [weak self] (authResult, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        print("Error signing in anonymously: \(error.localizedDescription)")
                    } else if let user = authResult?.user {
                        print("Anonymous user registered: \(user.uid)")
                        if let selectedImage = myimage.image {
                            self.saveUserDataToFirestore(uid: user.uid, username: username, image: selectedImage)
                        }
                    }
                }
            }
        } else {
            showAlert(title: "Error", message: "Please enter your username.")
        }
    }

    
    func saveUserDataToFirestore(uid: String, username: String, image: UIImage) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("user_images/\(uid).jpg")

        // Convert UIImage to Data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.showAlert(title: "Upload Error", message: error.localizedDescription)
                    print("Upload Error: \(error.localizedDescription)")
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        self.showAlert(title: "Download URL Error", message: error.localizedDescription)
                        print("Download URL Error: \(error.localizedDescription)")
                        return
                    }

                    if let downloadURL = url {
                        print("Image uploaded successfully: \(downloadURL.absoluteString)")

                        if let currentUser = Auth.auth().currentUser {
                            let changeRequest = currentUser.createProfileChangeRequest()
                            changeRequest.displayName = username
                            changeRequest.photoURL = downloadURL
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    self.showAlert(title: "Profile Update Error", message: error.localizedDescription)
                                    print("Profile Update Error: \(error.localizedDescription)")
                                    return
                                }

                                let firestore = Firestore.firestore()
                                let userData: [String: Any] = [
                                    "uid": uid,
                                    "username": username,
                                    "imageURL": downloadURL.absoluteString
                                ]

                                firestore.collection("users").document(uid).setData(userData) { error in
                                    if let error = error {
                                        self.showAlert(title: "Firestore Error", message: error.localizedDescription)
                                        print("Firestore Error: \(error.localizedDescription)")
                                    } else {
                                        print("User data saved successfully to Firestore")
                                        self.performSegue(withIdentifier: "showmain", sender: self)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    @IBAction func random(_ sender: Any) {
        let randomIndex = Int(arc4random_uniform(UInt32(namelist.count)))
        myname.text = namelist[randomIndex]

        let randomImageName = imagelist[randomIndex]
        myimage.image = UIImage(named: randomImageName)
    }
    
    // Function to dismiss the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Function to show an alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    public func moveToNextScene(){
        self.performSegue(withIdentifier: "showmain", sender: self)
    }
    
    func performLoginAndSegue(with username: String) {
        loginViewController.name = username

        if let user = Auth.auth().currentUser {
            print("User already logged in: \(user.uid)")
            self.performSegue(withIdentifier: "showmain", sender: self)
        } else {
            Auth.auth().signInAnonymously { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error signing in anonymously: \(error.localizedDescription)")
                } else if let user = authResult?.user {
                    print("Anonymous user registered: \(user.uid)")
                    self.performSegue(withIdentifier: "showmain", sender: self)
                }
            }
        }
    }
}



//import UIKit
//
//class loginViewController: UIViewController {
//    
//    // A variable to store the currently logged-in user's name
//    static var name: String = ""
//    @IBOutlet weak var myimage: UIImageView!
//    var imagelist:[String] = ["1","2","3","4","5","6","7","8","9","10"]
//    var namelist:[String] = [
//        "ShadowHunter",
//        "NightmareWizard",
//        "MysticKnight",
//        "ThunderFury",
//        "DragonSlayer",
//        "PhoenixRider",
//        "SilverWolf",
//        "DarkValkyrie",
//        "ArcaneSorcerer",
//        "StormChaser"
//    ]
//
//
//    @IBOutlet weak var myname: UITextField!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Add tap gesture to dismiss keyboard when tapping anywhere on the screen
//        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture1)
//    }
//    
//    @IBAction func loginTapped(_ sender: Any) {
//        if let username = myname.text, !username.isEmpty {
//            // If the text field is not empty, proceed to the next screen
//            loginViewController.name = self.myname.text!
//            self.performSegue(withIdentifier: "showmain", sender: true)
//        } else {
//            // Show an alert if the text field is empty
//            showAlert(title: "Error", message: "Please enter your username.")
//        }
//    }
//
//    
//    @IBAction func random(_ sender: Any) {
//        let randomIndex = Int(arc4random_uniform(UInt32(namelist.count)))
//        myname.text = namelist[randomIndex]
//    
//        // Update the image based on the random selection
//        let randomImageName = imagelist[randomIndex]
//        myimage.image = UIImage(named: randomImageName)
//    }
//
//    
//    // Function to dismiss the keyboard
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    
//    // Function to show an alert
//    func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//}
