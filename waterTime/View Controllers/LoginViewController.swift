//
//  LoginViewController.swift
//  waterTime
//
//  Created by Клоун on 29.05.2022.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    private lazy var facebookButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.height - 100, width: view.frame.width - 64, height: 45)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.delegate = self
        loginButton.addTarget(self, action: #selector(handleFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    private lazy var googleSignInButton: UIButton = {
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.height - 150, width: view.frame.width - 64, height: 45)
        loginButton.setTitle("Login With Google", for: .normal)
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        enableLoginButton(enabled: false)
        loginActivityIndicator.hidesWhenStopped = true
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    @IBAction func loginIntoApp(_ sender: UIButton) {
        enableLoginButton(enabled: false)
        loginActivityIndicator.isHidden = false
        loginActivityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
        
        AuthService.shared.loginIntoApp(email: email, password: password) { [unowned self] result in
            switch result {
            case .success(_):
                presentingViewController?.dismiss(animated: true)
            case .failure(let error):
                enableLoginButton(enabled: true)
                loginActivityIndicator.stopAnimating()
                showAlert(error.localizedDescription)
            }
        }
    }
    
    //MARK: Setup View
    private func setupViews() {
        view.addSubview(facebookButton)
        view.addSubview(googleSignInButton)
    }
    
    private func enableLoginButton(enabled: Bool) {
        if enabled {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    private func showAlert(_ error: String? = nil) {
        let alertMessage = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default)
        alertMessage.addAction(action)
        present(alertMessage, animated: true)
    }
    
    @objc private func textFieldChanged() {
        guard let emailTF = emailTextField.text,
              let passwordTF = passwordTextField.text
        else { return }
        let textFieldFilled = !(emailTF.isEmpty) && !(passwordTF.isEmpty)
        enableLoginButton(enabled: textFieldFilled)
    }
}

//MARK: Extension For Login Buttons
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        AuthService.shared.loginButton(error)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
    
    //MARK: Sign Into Firebase
    private func signIntoFirebase() {
        AuthService.shared.signIntoFirebase()
    }
    
    //MARK: Fetch Facebook Fields
    private func fetchingFacebookFields() {
        AuthService.shared.fetchingFacebookFields()
    }
    
    //MARK: Save Into Firebase
    private func saveIntoFirebase() {
        AuthService.shared.saveIntoFirebase {
            self.openMainViewController()
        }
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    //MARK: Selectors For Login Button
    @objc private func handleFBLogin() {
        AuthService.shared.handleFBLogin()
    }
    
    @objc private func googleSignIn() {
        AuthService.shared.googleSignIn(self) {
            self.openMainViewController()
        }
    }
}
