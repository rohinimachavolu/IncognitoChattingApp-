
import UIKit

class ImageBubbleTableViewCell: MyBubbleViewCell, CustomAttachedImageProtocol {
    
    @IBOutlet weak var imgView: UIImageView!
    var imageData: CustomAttachedImageData? {
        didSet {
            imageUpdate(to: imgView)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        //        self.imgData.layer.borderWidth = 1.0
        addGesture(to: self.imgView, target: self, action: #selector(actAttachedImage(sender:)))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setBubbleData(data: customBubbleData) {
        
        self.lbTime.text = data.date._stringFromDateFormat("a h:mm")
        self.imageData = data.imageData
        
    }
    @objc func actAttachedImage(sender : UIGestureRecognizer){
        if let loadedImage = self.imageData?.image {
            self.gestureTarget?.attachedImagePressed(cell: self,tappedImage:loadedImage)
        }
        
    }
}
