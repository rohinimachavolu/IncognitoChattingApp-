import Foundation

import UIKit

class AlertUtil {

    static func showAlertAndReturnToRoot(on viewController: UIViewController, title: String, message: String) {
        NotificationCenter.default.post(
            name: Notification.Name("Refresh"),
            object: nil
        )
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            viewController.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)

        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showRegularAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(confirmAction)

        viewController.present(alert, animated: true, completion: nil)
    }
}
