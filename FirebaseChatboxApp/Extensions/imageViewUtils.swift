
import Foundation
import UIKit

extension UIImageView {
    func loadRemoteImage(from url: URL?) {
        guard let url = url else {
            self.image = UIImage(systemName: "person.crop.circle")
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.image = UIImage(systemName: "person.crop.circle")
                }
            }
        }
    }
}

