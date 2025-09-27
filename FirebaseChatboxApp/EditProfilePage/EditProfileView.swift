import UIKit

class EditProfileView: UIView {
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var textFieldName: UITextField!
//    var textFieldEmail: UITextField!
//    var textFieldPassword: UITextField!
//    var textFieldConfirmPassword: UITextField!
    var saveButton: UIButton!
    
    var labelPhoto: UILabel!
    var buttonTakePhoto: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupScrollView()
        setupContentView()
        
        setuptextFieldName()
//        setuptextFieldEmail()
//        setuptextFieldPassword()
//        setupTextFieldConfirmPassword()
        setupbuttonRegister()
        
        setuplabelPhoto()
        setupbuttonTakePhoto()
        
        initConstraints()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func setupContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setuptextFieldName() {
        textFieldName = UITextField()
        textFieldName.placeholder = "Name"
        textFieldName.keyboardType = .default
        textFieldName.borderStyle = .roundedRect
        textFieldName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldName)
    }
    
//    func setuptextFieldEmail() {
//        textFieldEmail = UITextField()
//        textFieldEmail.placeholder = "Email"
//        textFieldEmail.keyboardType = .emailAddress
//        textFieldEmail.borderStyle = .roundedRect
//        textFieldEmail.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(textFieldEmail)
//    }
//    
//    func setuptextFieldPassword() {
//        textFieldPassword = UITextField()
//        textFieldPassword.isSecureTextEntry = true
//        textFieldPassword.textContentType = .none
//        textFieldPassword.placeholder = "Password"
//        textFieldPassword.borderStyle = .roundedRect
//        textFieldPassword.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(textFieldPassword)
//    }
//    
//    func setupTextFieldConfirmPassword() {
//        textFieldConfirmPassword = UITextField()
//        textFieldConfirmPassword.isSecureTextEntry = true
//        textFieldConfirmPassword.textContentType = .none
//        textFieldConfirmPassword.placeholder = "Confirm Password"
//        textFieldConfirmPassword.borderStyle = .roundedRect
//        textFieldConfirmPassword.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(textFieldConfirmPassword)
//    }
    
    func setupbuttonRegister() {
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(saveButton)
    }

    
    func setuplabelPhoto() {
        labelPhoto = UILabel()
        labelPhoto.text = "Tap and hold the picture to edit"
        labelPhoto.font = UIFont.boldSystemFont(ofSize: 14)
        labelPhoto.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelPhoto)
    }
    
    func setupbuttonTakePhoto() {
        buttonTakePhoto = UIButton(type: .system)
        buttonTakePhoto.setTitle("", for: .normal)
        buttonTakePhoto.setImage(UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
        buttonTakePhoto.contentHorizontalAlignment = .fill
        buttonTakePhoto.contentVerticalAlignment = .fill
        buttonTakePhoto.imageView?.contentMode = .scaleAspectFit
        buttonTakePhoto.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonTakePhoto)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            textFieldName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 64),
            textFieldName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textFieldName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
//            textFieldEmail.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 16),
//            textFieldEmail.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            textFieldEmail.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
//            
//            textFieldPassword.topAnchor.constraint(equalTo: textFieldEmail.bottomAnchor, constant: 16),
//            textFieldPassword.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            textFieldPassword.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
//            
//            textFieldConfirmPassword.topAnchor.constraint(equalTo: textFieldPassword.bottomAnchor, constant: 16),
//            textFieldConfirmPassword.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            textFieldConfirmPassword.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            buttonTakePhoto.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 30),
            buttonTakePhoto.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonTakePhoto.widthAnchor.constraint(equalToConstant: 100),
            buttonTakePhoto.heightAnchor.constraint(equalToConstant: 100),
            
            labelPhoto.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor, constant: 30),
            labelPhoto.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor),
            labelPhoto.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: labelPhoto.bottomAnchor, constant: 32),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

