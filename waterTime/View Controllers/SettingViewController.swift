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
    @IBOutlet weak var sliderOutlet: UISlider!
    
    var delegate: SettingViewControllerDelegate?
    
    private var newDataForLabel: Float?
    private var newValueForSlider = UserDefaults.standard.float(forKey: "slider_value")
    
    private lazy var logOutButton: UIButton = {
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
        view.addSubview(logOutButton)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        newDataForLabel = sender.value
        UserDefaults.standard.set(sender.value, forKey: "slider_value")
        guard
            let delegate = delegate,
            let newDataForLabel = newDataForLabel
        else { return }
        delegate.fillLabel(text: String(Int(newDataForLabel)))
    }
    
    private func openLoginViewController() {
        LogOutService.shared.openLoginVC { [weak self] loginVC in
            self?.present(loginVC, animated: true)
        }
        
    }
    
    @objc private func signOut() {
        LogOutService.shared.signOutFromProvider {
            openLoginViewController()
        }
    }
}
