

import UIKit

class MyBubbleViewCell: UITableViewCell {
    
    @IBOutlet weak var lbText: UILabel?
    @IBOutlet weak var lbTime: UILabel!
    weak var gestureTarget:BubbleViewCellEventDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(longTap(sender:)))
        longPressed.delegate = self
        self.lbText?.addGestureRecognizer(longPressed)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBubbleData(data: customBubbleData) {
    
        if data.userData.userNickName == "我"{
            self.lbText?.text =  "     " + String(data.text!)
            self.lbTime.text = data.date._stringFromDateFormat("a h:mm")
            let playIconImageView = UIImageView(image: UIImage(systemName: "play.circle.fill")) // 使用 SF Symbols 播放图标
         
            playIconImageView.tintColor = .blue // 设置图标颜色
            playIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // 设置播放图标的大小和位置
            self.lbText?.addSubview(playIconImageView) // 将播放图标添加到 lbText 标签上
        }else{
            self.lbText?.text =   data.text
            self.lbTime.text = data.date._stringFromDateFormat("a h:mm")
        }
        
      
    }

    
    @objc func longTap(sender : UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            self.gestureTarget?.textLongPressed(cell: self)
//            self.gestureTarget?.textLongPressed?(cell:self, text:self.lbText!.text!)
        }
    }
    
//    func textLongPressed() {
//        
//    }
    
}
