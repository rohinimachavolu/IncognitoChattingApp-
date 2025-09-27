import UIKit

class LandingView: UIView {
    
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView() // 新增 contentView 作为容器
    let imageView = UIImageView()
    let descriptionLabel = UILabel()
    let button1 = UIButton(type: .system)
    let button2 = UIButton(type: .system)
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupScrollView()
        setupContentView()
        setupImageView()
        setupDescriptionLabel()
        setupButtons()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        setupScrollView()
        setupContentView()
        setupImageView()
        setupDescriptionLabel()
        setupButtons()
        layoutUI()
    }
    
    // MARK: - Setup ScrollView
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
    }
    
    // MARK: - Setup ContentView
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    // MARK: - Setup ImageView
    private func setupImageView() {
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
    }
    
    // MARK: - Setup Description Label
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Chat without an identity"
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
    }
    
    // MARK: - Setup Buttons
    private func setupButtons() {
        // Button 1
        button1.setTitle("Continue", for: .normal)
        button1.backgroundColor = .systemBlue
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 8
        button1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button1)
        
        // Button 2
        button2.setTitle("New Account", for: .normal)
        button2.backgroundColor = .systemGreen
        button2.setTitleColor(.white, for: .normal)
        button2.layer.cornerRadius = 8
        button2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button2)
    }
    
    // MARK: - Layout UI Components
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // ImageView constraints
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Description Label constraints
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Button 1 constraints
            button1.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            button1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button1.widthAnchor.constraint(equalToConstant: 200),
            button1.heightAnchor.constraint(equalToConstant: 50),
            
            // Button 2 constraints
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 20),
            button2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button2.widthAnchor.constraint(equalToConstant: 200),
            button2.heightAnchor.constraint(equalToConstant: 50),
            
            // Bottom constraint for contentView to enable scrolling
            button2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60)
        ])
    }
}
