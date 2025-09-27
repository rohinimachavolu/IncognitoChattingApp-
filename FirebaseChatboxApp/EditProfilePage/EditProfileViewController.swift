import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class EditProfileController: UIViewController {
    
    var profileName: String?
    var profileImage: UIImage?
    
    let editProfileView = EditProfileView()
    var targetScrollView: UIScrollView!
    var activeTextField: UITextField?

    
    let childProgressView = ProgressSpinnerViewController()
    
    let storage = Storage.storage()
    
    //MARK: variable to store the picked Image...
    var pickedImage:UIImage?
    
    override func loadView() {
        view = editProfileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpForResponsiveKeypad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        editProfileView.buttonTakePhoto.menu = getMenuImagePicker()
        
        editProfileView.saveButton.addTarget(self, action: #selector(onSaveBtnTapped), for: .touchUpInside)
        title = "Edit Profile"
        
        configureData()
    }
    
    //MARK: menu for buttonTakePhoto setup...
    func getMenuImagePicker() -> UIMenu{
        let menuItems = [
            UIAction(title: "Camera",handler: {(_) in
                self.pickUsingCamera()
            }),
            UIAction(title: "Gallery",handler: {(_) in
                self.pickPhotoFromGallery()
            })
        ]
        
        return UIMenu(title: "Select source", children: menuItems)
    }
    
    private func configureData() {
        editProfileView.textFieldName.text = profileName
        pickedImage = profileImage ?? UIImage(systemName: "person.circle")
        if let image = pickedImage {
            editProfileView.buttonTakePhoto.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    //MARK: take Photo using Camera...
    func pickUsingCamera(){
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        present(cameraController, animated: true)
    }
    
    //MARK: pick Photo using Gallery...
    func pickPhotoFromGallery(){
        //MARK: Photo from Gallery...
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1
        
        let photoPicker = PHPickerViewController(configuration: configuration)
        
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
    @objc func onSaveBtnTapped(){
        //MARK: creating a new user on Firebase with photo...
        if(checkAllInputs() == false){return}
        showActivityIndicator()
        updateProfile(name: editProfileView.textFieldName.text ?? "Default Name")
    }
}

// check input functions
extension EditProfileController{
    func checkAllInputs() -> Bool {
        guard let name = editProfileView.textFieldName.text else{
            return false;
        }
        
        if(name.isEmpty){
            AlertUtil.showRegularAlert(on: self, title: "Error", message: "Empty input is not allowed.")
            return false;
        }
        return true;
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func isValidPassword(_ password: String) -> Bool {
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedPassword.count >= 6
    }
    
    func arePasswordsMatching(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
}

extension EditProfileController: UITextFieldDelegate{
    func setUpHideKeyboardTappedOutside(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    @objc func hideKeyboardOnTap(){
        //MARK: removing the keyboard from screen...
        view.endEditing(true)
    }
    
    func setUpForResponsiveKeypad(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setUpHideKeyboardTappedOutside()
        
        targetScrollView = editProfileView.scrollView
        editProfileView.textFieldName.delegate = self
//        editProfileView.textFieldEmail.delegate = self
//        editProfileView.textFieldPassword.delegate = self
//        editProfileView.textFieldConfirmPassword.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        targetScrollView.contentInset = contentInsets
        targetScrollView.scrollIndicatorInsets = contentInsets
        
        if let activeField = activeTextField {
            var visibleRect = self.view.frame
            visibleRect.size.height -= keyboardSize.height
            
            let activeFieldFrame = activeField.convert(activeField.bounds, to: self.view)
            if !visibleRect.contains(activeFieldFrame.origin) {
                targetScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }


    @objc func keyboardWillHide(notification: NSNotification) {
        targetScrollView.contentInset = .zero
        targetScrollView.scrollIndicatorInsets = .zero
    }
}



extension EditProfileController{
    func updateProfile(name: String) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let imageToUpload = pickedImage ?? UIImage(systemName: "person.crop.circle")!
        
        if let jpgData = imageToUpload.jpegData(compressionQuality: 0.8) {
            let storageRef = storage.reference()
            let imagesRepo = storageRef.child("user_images")
            let imageRef = imagesRepo.child("\(UUID().uuidString).jpg")
            
            imageRef.putData(jpgData) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let profilePhotoURL = url {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        changeRequest.photoURL = profilePhotoURL
                        
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Error updating profile: \(error.localizedDescription)")
                            } else {
                                print("Profile updated successfully.")
                                self.updateFirestoreUserProfile(userID: user.uid, name: name, photoURL: profilePhotoURL)
                            }
                        }
                    }
                }
            }
        } else {
            print("Failed to convert image to JPG data.")
        }
    }

    func updateFirestoreUserProfile(userID: String, name: String, photoURL: URL) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData([
            "username": name,
            "imageURL": photoURL.absoluteString
        ]) { error in
            if let error = error {
                print("Error updating Firestore user data: \(error.localizedDescription)")
                AlertUtil.showRegularAlert(on: self, title: "Error", message: "\(error.localizedDescription)")
            } else {
                print("Firestore user data updated successfully.")
                NotificationCenter.default.post(name: Notification.Name("updateUserProfile"), object: nil)
                self.hideActivityIndicator();
                let alert = UIAlertController(title: "Success", message: "Profile Updated", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
//                if let presentingVC = self.presentingViewController {
//                    print("function called")
//                    self.showSuccessAlert(on: presentingVC)
//                }
            }
        }
    }
    
    func showSuccessAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Success", message: "Profile Updated", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            viewController.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    
    func setNameAndPhotoOfTheUserInFirebaseAuth(name: String, email: String, photoURL: URL?) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.photoURL = photoURL
        
        print("\(String(describing: photoURL))")
        changeRequest?.commitChanges(completion: { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error occurred: \(error)")
            } else {
                print("Profile updated successfully.")
                
                // make sure user is login
                guard let user = Auth.auth().currentUser else { return }
                let userUID = user.uid
                let database = Firestore.firestore()
                let userDocument = database.collection("users").document(email)
                
                // record user display name and photourl into firebase
                userDocument.setData([
                    "displayName": name,
                    "photoURL": photoURL?.absoluteString ?? ""
                ]) { error in
                    if let error = error {
                        print("Error writing to Firestore: \(error)")
                    } else {
                        print("User information successfully written to Firestore.")
                        
                        // fetch all existing user and add new user to their chats
                        self.addNewUserWithChannels(newUserEmail: email, newUserName: name, newUserPhotoURL: photoURL, newUserUID:userUID)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.hideActivityIndicator()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    // create one on one chat channel
    func addNewUserWithChannels(newUserEmail: String, newUserName: String, newUserPhotoURL: URL?, newUserUID: String) {
        let database = Firestore.firestore()
        let usersCollection = database.collection("users")
        let channelsCollection = database.collection("channels")
        
        // fetch all users
        usersCollection.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for document in snapshot.documents {
                let existingUserEmail = document.documentID
                let existingUserUID = document.data()["uid"] as? String ?? ""
                
                // skip the new user
                if existingUserEmail == newUserEmail { continue }
                
                // generate uid for each chat channel
                let channelId = self.generateChannelId(newUserEmail: newUserEmail, existingUserEmail: existingUserEmail)
                
                // create document for each chat channel
                let channelDocument = channelsCollection.document(channelId)
                channelDocument.setData([
                    "user1": newUserEmail,
                    "user2": existingUserEmail,
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error creating channel document: \(error)")
                    } else {
                        print("Successfully created channel for \(newUserEmail) and \(existingUserEmail)")
                        
                        let existingUserName = document.data()["displayName"] as? String ?? "Unknown"
                        let existingUserPhotoURL = document.data()["photoURL"] as? String ?? ""
                        
                        let newUserChats = usersCollection.document(newUserEmail).collection("chats")
                        newUserChats.document(existingUserEmail).setData([
                            "channelId": channelId,
                            "displayName": existingUserName,
                            "email": existingUserEmail,
                            "photoURL": existingUserPhotoURL,
                            "uid": existingUserUID
                        ]) { error in
                            if let error = error {
                                print("Error adding channel reference to new user's chats: \(error)")
                            } else {
                                print("Successfully added channel reference for \(newUserEmail)")
                            }
                        }
                        
                        let existingUserChats = usersCollection.document(existingUserEmail).collection("chats")
                        existingUserChats.document(newUserEmail).setData([
                            "channelId": channelId,
                            "displayName": newUserName,
                            "email": newUserEmail,
                            "photoURL": newUserPhotoURL?.absoluteString ?? "",
                            "uid": newUserUID
                        ]) { error in
                            if let error = error {
                                print("Error adding channel reference to existing user's chats: \(error)")
                            } else {
                                print("Successfully added channel reference for \(existingUserEmail)")
                            }
                        }
                    }
                }
            }
        }
    }



    func generateChannelId(newUserEmail: String, existingUserEmail: String) -> String {
        return [newUserEmail, existingUserEmail].sorted().joined(separator: "_")
    }
}

extension EditProfileController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}

import PhotosUI

//MARK: adopting required protocols for PHPicker...
extension EditProfileController:PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        print(results)
        
        let itemprovider = results.map(\.itemProvider)
        
        for item in itemprovider{
            if item.canLoadObject(ofClass: UIImage.self){
                item.loadObject(
                    ofClass: UIImage.self,
                    completionHandler: { (image, error) in
                        DispatchQueue.main.async{
                            if let uwImage = image as? UIImage{
                                self.editProfileView.buttonTakePhoto.setImage(
                                    uwImage.withRenderingMode(.alwaysOriginal),
                                    for: .normal
                                )
                                self.pickedImage = uwImage
                            }
                        }
                    }
                )
            }
        }
    }
}

//MARK: adopting required protocols for UIImagePicker...
extension EditProfileController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage{
            self.editProfileView.buttonTakePhoto.setImage(
                image.withRenderingMode(.alwaysOriginal),
                for: .normal
            )
            self.pickedImage = image
        }else{
            // Do your thing for No image loaded...
        }
    }
}
