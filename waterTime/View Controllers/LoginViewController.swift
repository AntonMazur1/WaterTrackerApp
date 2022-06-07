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
    
    var userProfile: User?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    lazy var facebookButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.height - 100, width: view.frame.width - 64, height: 45)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.delegate = self
        loginButton.addTarget(self, action: #selector(handleFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var googleSignInButton: UIButton = {
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
        loginActivityIndicator.isHidden = true
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
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                
                self.enableLoginButton(enabled: true)
                self.loginActivityIndicator.isHidden = true
                self.loginActivityIndicator.stopAnimating()
                
                let alertMessage = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "ОК", style: .default)
                alertMessage.addAction(action)
                self.present(alertMessage, animated: true)
                
                return
            }
            
            self.presentingViewController?.dismiss(animated: true)
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
    
    @objc func textFieldChanged() {
        guard let emailTF = emailTextField.text,
              let passwordTF = passwordTextField.text
        else { return }
        
        let textFieldFilled =
        !(emailTF.isEmpty) &&
        !(passwordTF.isEmpty)
        
        enableLoginButton(enabled: textFieldFilled)
    }
}

//MARK: Extension For Login Buttons
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard Auth.auth().currentUser != nil else { return }
        
        signIntoFirebase()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Log out From FaceBook")
    }
    
    //MARK: Selector For Login Button
    @objc private func handleFBLogin() {
        let manager = LoginManager()
        manager.logIn(permissions: ["email", "public_profile"], from: self) { result, error in
            if let error = error {
                print(error)
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.signIntoFirebase()
            }
        }
    }
    
    @objc func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            print(error)
            return
          }
            
            if let userName = user?.profile?.name, let userEmail = user?.profile?.email {
                let userData = ["name": userName, "email": userEmail]
                self.userProfile = User(data: userData)
            }
            
            print("Success")
          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error)
                    return
                }
                
                print("Successfully logged in Firebase")
                self.saveIntoFirebase()
            }
          
        }
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    //MARK: Sign Into Firebase
    private func signIntoFirebase() {
        let accessToken = AccessToken.current
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { user, error in
            if let error = error {
                print(error)
                return
            }
            
            self.fetchingFacebookFields()
            print(user!)
        }
    }
    
    //MARK: Fetch Facebook Fields
    private func fetchingFacebookFields() {
        
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"id, name, email"])
        request.start() { connection, result, error in
            if let result = result as? [String: Any], error == nil {
                self.userProfile = User(data: result)
                print("fetched user: \(self.userProfile?.name ?? "")")
            }
            self.saveIntoFirebase()
        }
    }
    
    //MARK: Save Into Firebase
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name,"email": userProfile?.email]
        let values = [uid: userData]
        
        Database.database().reference().child("Users").updateChildValues(values) { error, _ in
            if let error = error {
                print(error)
                return
            }
            self.openMainViewController()
            print("User saved")
        }
    }
}
