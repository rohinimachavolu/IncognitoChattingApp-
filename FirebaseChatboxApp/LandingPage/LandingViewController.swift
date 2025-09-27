import UIKit
import FirebaseAuth
import Network

class LandingViewController: UIViewController {
    
    // MARK: - Properties
    let landingView = LandingView()
    let monitor = NWPathMonitor()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = landingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        checkAuthState()
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        landingView.button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        landingView.button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    @objc private func button1Tapped() {
        checkNetworkConnection {
            print("Get Started button tapped")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController {
                tabBarVC.modalPresentationStyle = .fullScreen
                self.present(tabBarVC, animated: true, completion: nil)
            } else {
                print("Error: Could not instantiate tabbar from Storyboard")
            }
        }
    }
    
    @objc private func button2Tapped() {
        checkNetworkConnection {
            print("Learn More button tapped")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? loginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            } else {
                print("Error: Could not instantiate loginViewController from Storyboard")
            }
        }
    }
    
    // MARK: - Check Firebase Auth State
    private func checkAuthState() {
        if Auth.auth().currentUser == nil {
            landingView.button1.isHidden = true
        } else {
            landingView.button1.isHidden = false
        }
    }
    
    // MARK: - Network Connection Check
    private func checkNetworkConnection(completion: @escaping () -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    completion()
                } else {
                    self.showNoNetworkAlert()
                }
                self.monitor.cancel()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    // MARK: - Show No Network Alert
    private func showNoNetworkAlert() {
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your network settings and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
