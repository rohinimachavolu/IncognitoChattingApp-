

import Foundation
import UIKit

@IBDesignable
class RoundCircleClass: UIView {
    @IBInspectable var radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 2.0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyShadow()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyShadow()
    }

    private func applyShadow() {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
    }
}
