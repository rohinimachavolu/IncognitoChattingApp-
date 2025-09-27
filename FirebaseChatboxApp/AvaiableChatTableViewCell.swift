import UIKit

class AvaiableChatTableViewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()

    public let roomNameTxt: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    public let roomidText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()

    public let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
    }()

    public let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {

        contentView.addSubview(containerView)
        containerView.addSubview(roomNameTxt)
        containerView.addSubview(roomidText)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            roomNameTxt.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            roomNameTxt.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            roomNameTxt.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dateLabel.widthAnchor.constraint(equalToConstant: 100)
        ])

        NSLayoutConstraint.activate([
            roomidText.topAnchor.constraint(equalTo: roomNameTxt.bottomAnchor, constant: 8),
            roomidText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            roomidText.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            roomidText.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow()
    }

    private func addShadow() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: 12).cgPath
    }

    // 配置方法
    func configure(roomName: String, roomId: String, date: String, time: String) {
        roomNameTxt.text = roomName
        roomidText.text = roomId
        dateLabel.text = date
        timeLabel.text = time
    }
}
