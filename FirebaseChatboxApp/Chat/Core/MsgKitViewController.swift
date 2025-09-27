import UIKit
import Photos
import Firebase
import FirebaseAuth
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseStorage

final class ChatViewController: MessagesViewController {
  private var isSendingPhoto = false {
    didSet {
      messageInputBar.leftStackViewItems.forEach { item in
        guard let item = item as? InputBarButtonItem else {
          return
        }
        item.isEnabled = !self.isSendingPhoto
      }
    }
  }

  private let database = Firestore.firestore()
  private var reference: CollectionReference?
  private let storage = Storage.storage().reference()

  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?

  private let user: User
  private let channel: Channel
  
    public var chatEndTime: String?;
    private var countdownTimer: Timer?

  deinit {
    messageListener?.remove()
    countdownTimer?.invalidate()
  }

  init(user: User, channel: Channel) {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)

    title = channel.name
  }
    
    @objc func rightButtonTapped() {
        print("Right button tapped!")
    }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    listenToMessages()
    navigationItem.largeTitleDisplayMode = .never
    setUpMessageView()
//    removeMessageAvatars()
    addCameraBarButton()
      
      setUpTimeCount(with: chatEndTime ?? "No End Time")
//      setUpTimeCount(with: "Dec 29, 2024 at 23:54")
      
//      guard let channelId = channel.id else {
//          print("channel.id is nil")
//          return
//      }
//      
//      fetchTimeForChannel(channelId: channelId) { [weak self] time in
//          DispatchQueue.main.asyncAfter(deadline: .now() + 2)  {
//              if let time = time {
//                  self?.setUpTimeCount(with: time)
//              } else {
//                  self?.setUpTimeCount(with: "No End Time")
//              }
//          }
//      }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
    tapRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(tapRecognizer)
  }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesCollectionView.scrollToLastItem(animated: true)

    }

  
  @objc private func hideKeyboardOnTap(){
      //MARK: removing the keyboard from screen...
      view.endEditing(true)
  }
  
  private func listenToMessages() {
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }

    reference = database.collection("teams/\(id)/thread")

    messageListener = reference?.addSnapshotListener { [weak self] querySnapshot, error in
      guard let self = self else { return }
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }

      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
      
      // Ensure the MessageKit layout updates for the new orientation
      coordinator.animate(alongsideTransition: { _ in
          self.messagesCollectionView.collectionViewLayout.invalidateLayout()
      }, completion: nil)
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return .all
  }


  private func setUpMessageView() {
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .primary
    messageInputBar.sendButton.setTitleColor(.primary, for: .normal)

    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }

  private func removeMessageAvatars() {
    guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
      return
    }
    layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
    layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    layout.setMessageIncomingAvatarSize(.zero)
    layout.setMessageOutgoingAvatarSize(.zero)
    let incomingLabelAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
    let outgoingLabelAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
    layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
  }

  private func addCameraBarButton() {
    let cameraItem = InputBarButtonItem(type: .system)
    cameraItem.tintColor = .primary
    cameraItem.image = UIImage(named: "camera")
    cameraItem.addTarget(
      self,
      action: #selector(cameraButtonPressed),
      for: .primaryActionTriggered)
    cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)

    messageInputBar.leftStackView.alignment = .center
    messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
    messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
  }

  // MARK: - Actions
  @objc private func cameraButtonPressed() {
    let picker = UIImagePickerController()
    picker.delegate = self

    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }

    present(picker, animated: true)
  }

  // MARK: - Helpers
  private func save(_ message: Message) {
    reference?.addDocument(data: message.representation) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("Error sending message: \(error.localizedDescription)")
        return
      }
      self.messagesCollectionView.scrollToLastItem()
    }
  }

  private func insertNewMessage(_ message: Message) {
    if messages.contains(message) {
      return
    }

    messages.append(message)
    messages.sort()

    let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
    let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage

    messagesCollectionView.reloadData()

    if shouldScrollToBottom {
      messagesCollectionView.scrollToLastItem(animated: true)
    }
  }

  private func handleDocumentChange(_ change: DocumentChange) {
    guard var message = Message(document: change.document) else {
      return
    }

    switch change.type {
    case .added:
      if let url = message.downloadURL {
        downloadImage(at: url) { [weak self] image in
          guard
            let self = self,
            let image = image
          else {
            return
          }
          message.image = image
          self.insertNewMessage(message)
        }
      } else {
        insertNewMessage(message)
      }
    default:
      break
    }
  }

  private func uploadImage(
    _ image: UIImage,
    to channel: Channel,
    completion: @escaping (URL?) -> Void
  ) {
    guard
      let channelId = channel.id,
      let scaledImage = image.scaledToSafeUploadSize,
      let data = scaledImage.jpegData(compressionQuality: 0.4)
    else {
      return completion(nil)
    }

    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"

    let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
    let imageReference = storage.child("\(channelId)/\(imageName)")
    imageReference.putData(data, metadata: metadata) { _, _ in
      imageReference.downloadURL { url, _ in
        completion(url)
      }
    }
  }

  private func sendPhoto(_ image: UIImage) {
    isSendingPhoto = true

    uploadImage(image, to: channel) { [weak self] url in
      guard let self = self else { return }
      self.isSendingPhoto = false

      guard let url = url else {
        return
      }

        AppSettings.displayName = self.user.displayName ?? "Default Name"
        var message = Message(user: self.user, image: image)
      message.downloadURL = url

      self.save(message)
      self.messagesCollectionView.scrollToLastItem()
    }
  }

  private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
    let ref = Storage.storage().reference(forURL: url.absoluteString)
    let megaByte = Int64(1 * 1024 * 1024)

    ref.getData(maxSize: megaByte) { data, _ in
      guard let imageData = data else {
        completion(nil)
        return
      }
      completion(UIImage(data: imageData))
    }
  }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }

  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
    return false
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//    avatarView.isHidden = true
      avatarView.set(avatar: Avatar(image: UIImage(systemName: "person.circle.fill"), initials: "A"))
      print(message.sender.senderId)
      fetchUserAvatar(senderId: message.sender.senderId) { image in
          if let avatarImage = image {
              let avatar = Avatar(image: avatarImage, initials: "A")
              avatarView.set(avatar: avatar)
          } else {
              print("Failed to load avatar image.")
              let defaultAvatar = Avatar(image: UIImage(systemName: "person.circle.fill"), initials: "A")
              avatarView.set(avatar: defaultAvatar)
          }
      }
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 20
  }
  
  func messageBottomLabelAlignment(
      for message: MessageType,
      at _: IndexPath,
      in _: MessagesCollectionView
  ) -> LabelAlignment?{
//    return LabelAlignment(textAlignment: .right, textInsets: .zero)
      return isFromCurrentSender(message: message)
          ? LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 45))
          : LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 2, left: 45, bottom: 2, right: 10))
  }
    
  
  func messageBottomLabelHeight(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat{
    return 20
  }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    var currentSender: any MessageKit.SenderType {
        return Sender(senderId: user.uid, displayName: AppSettings.displayName)
    }
    
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }

//  func currentSender() -> SenderType {
//    return Sender(senderId: user.uid, displayName: AppSettings.displayName)
//  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }

  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ])
  }

  func messageBottomLabelAttributedText(
      for message: MessageType,
      at indexPath: IndexPath
  ) -> NSAttributedString?{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    let name = dateFormatter.string(from: message.sentDate)
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ])
  }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    let message = Message(user: user, content: text)
    save(message)
    inputBar.inputTextView.text = ""
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true)

    if let asset = info[.phAsset] as? PHAsset {
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(
        for: asset,
        targetSize: size,
        contentMode: .aspectFit,
        options: nil
      ) { result, _ in
        guard let image = result else {
          return
        }
        self.sendPhoto(image)
      }
    } else if let image = info[.originalImage] as? UIImage {
      sendPhoto(image)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
}


// for downloading avatar and fetching display names in realtime
extension ChatViewController {
    func fetchUserAvatar(senderId: String, completion: @escaping (UIImage?) -> Void) {
        let firestore = Firestore.firestore()
        
        firestore.collection("users").document(senderId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = document?.data(), let photoURLString = data["imageURL"] as? String, let photoURL = URL(string: photoURLString) {
                self.downloadImage(from: photoURL, completion: completion)
            } else {
                print("No photo URL found for user.")
                completion(nil)
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
}

// for chat time management
extension ChatViewController{
    private func setUpTimeCount(with timeString: String) {
        // parse string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let endDate = dateFormatter.date(from: timeString) else {
            print("Invalid date format: \(timeString)")
            return
        }
        
        // create ui label
        let countdownLabel = UILabel()
        countdownLabel.font = UIFont.systemFont(ofSize: 14)
        countdownLabel.textColor = .systemBlue
        countdownLabel.sizeToFit()
        countdownLabel.text = "Now Loading ..."
        
        let countdownItem = UIBarButtonItem(customView: countdownLabel)
        self.navigationItem.rightBarButtonItem = countdownItem
        

        self.navigationController?.navigationBar.layoutIfNeeded()
        
        // creater timer
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let timeRemaining = self?.calculateTimeRemaining(until: endDate) ?? "Time's up!"
            countdownLabel.text = timeRemaining
            
            if timeRemaining == "Time's up!" {
                self?.countdownTimer?.invalidate()
                self?.showTimeUpAlert()
            }
        }
    }

    
    func fetchTimeForChannel(channelId: String, completion: @escaping (String?) -> Void) {
        let firestore = Firestore.firestore()
        
        let documentRef = firestore.collection("teams").document(channelId)
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching channel: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("No matching channel found")
                completion(nil)
                return
            }
            
            if let time = document.data()?["time"] as? String {
                completion(time)
            } else {
                print("Time field not found in the document")
                completion(nil)
            }
        }
    }
    
    private func calculateTimeRemaining(until endDate: Date) -> String {
        let currentDate = Date()
        let timeInterval = endDate.timeIntervalSince(currentDate)
        
        if timeInterval <= 0 {
            return "Time's up!"
        }
        
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m \(seconds)s"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    private func showTimeUpAlert() {
        let alert = UIAlertController(title: "Time's Up!", message: "This chat has ended.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
