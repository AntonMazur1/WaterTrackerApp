//
//  SettingViewController.swift
//  waterTime
//
//  Created by Клоун on 25.04.2022.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class SettingViewController: UIViewController {
    
    var delegate: SettingViewControllerDelegate?
    var newDataForLabel: Float?
    var newValueForSlider = UserDefaults.standard.float(forKey: "slider_value")
    
    @IBOutlet weak var sliderOutlet: UISlider!
    
    lazy var logOutButton: UIButton = {
        let logOutButton = UIButton()
        logOutButton.frame = CGRect(x: 32, y: view.frame.height - 80, width: view.frame.width - 64, height: 45)
        logOutButton.backgroundColor = .black
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setTitleColor(.white, for: .normal)
        logOutButton.layer.masksToBounds = true
        logOutButton.layer.cornerRadius = logOutButton.frame.height / 2
        logOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return logOutButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderOutlet.value = newValueForSlider
        setupView()
    }
    
    @IBAction func slider(_ sender: UISlider) {
        newDataForLabel = sender.value
        UserDefaults.standard.set(sender.value, forKey: "slider_value")
        if let delegate = delegate{
            guard let newDataForLabel = newDataForLabel else { return }
            delegate.fillLabel(text: String(Int(newDataForLabel)))
        }
    }
    
    private func setupView() {
        view.addSubview(logOutButton)
    }
}

//MARK: Extension For Log Out Button
extension SettingViewController {
    
    //MARK: Sign Out From Firebase
    private func openLoginViewController() {
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.present(loginVC, animated: true)
                
                return
            }
        } catch {
            print(error)
        }
    }
    
    @objc func signOut() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for user in providerData {
                switch user.providerID {
                case "facebook.com":
                    let loginManager = LoginManager()
                    loginManager.logOut()
                    openLoginViewController()
                    print("User Successfully Log Out From Facebook")
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("User Successfully Log Out From Google")
                    openLoginViewController()
                case "password":
                    try! Auth.auth().signOut()
                    print("User Successfully Log Out From Email")
                    openLoginViewController()
                default:
                    print("Unknown Provider: \(user.providerID)")
                }
            }
        }
    }
}
