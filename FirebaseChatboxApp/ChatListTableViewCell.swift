
import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var usernameTxt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
