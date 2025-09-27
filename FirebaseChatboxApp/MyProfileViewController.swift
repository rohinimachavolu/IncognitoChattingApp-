
//import UIKit
//
//class MyProfileViewController: UIViewController {
//
//    @IBOutlet weak var name: UILabel!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.name.text = loginViewController.name
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
import UIKit
import FirebaseAuth

class MyProfileViewController: UIViewController {

    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
        setupContentView()
        
        contentView.addSubview(profilePic)
        contentView.addSubview(name)
        contentView.addSubview(editProfileButton)

        setupProfilePicConstraints()
        setupNameConstraints()
        setupEditProfileButtonConstraints()
        
        profilePic.image = nil
        setUserProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserProfile), name: Notification.Name("updateUserProfile"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup ScrollView
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Setup ContentView
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, constant: 20)
        ])

    }

    // MARK: - Setup ProfilePic Constraints
    private func setupProfilePicConstraints() {
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePic.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 200),
            profilePic.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profilePic.widthAnchor.constraint(equalToConstant: 100),
            profilePic.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: - Setup Name Constraints
    private func setupNameConstraints() {
        name.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: profilePic.bottomAnchor, constant: 20),
            name.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupEditProfileButtonConstraints() {
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.bringSubviewToFront(editProfileButton)


        NSLayoutConstraint.activate([
            editProfileButton.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20),
            editProfileButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editProfileButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Set User Profile
    @objc private func setUserProfile() {
        if let user = Auth.auth().currentUser {
            let displayName = user.displayName ?? "Anonymous User"
            name.text = displayName
            
            if let photoURL = user.photoURL {
                loadImage(from: photoURL)
            } else {
                profilePic.image = UIImage(systemName: "person.circle")
            }
        } else {
            name.text = "No User Logged In"
            profilePic.image = UIImage(systemName: "person.circle")
        }
    }
    
    // MARK: - Load Image from URL
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profilePic.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.profilePic.image = UIImage(systemName: "person.circle")
                }
            }
        }
    }
    
    @objc private func editProfileButtonTapped() {
        print("button tapped");
        let editProfileVC = EditProfileController()
        
        editProfileVC.profileName = name.text
        editProfileVC.profileImage = profilePic.image
        
        editProfileVC.modalPresentationStyle = .formSheet
        present(editProfileVC, animated: true, completion: nil)
    }
}
