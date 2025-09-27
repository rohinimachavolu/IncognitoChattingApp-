
import UIKit

class CustomBubbleViewHeaderCell: UITableViewCell {
    
    @IBOutlet weak var lbDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setDate(date:Date, withDay:Bool) {
        
        var strDate = date._stringFromDateFormat("yyyy/MM/dd")
        
        if withDay {
            strDate = strDate + " " + date._stringFromDateFormat("EEEEE").capitalized
        }
        self.lbDate.text = strDate
        
    }
}
