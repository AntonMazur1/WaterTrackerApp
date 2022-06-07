//
//  RegisterViewController.swift
//  waterTime
//
//  Created by Клоун on 04.06.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton(enable: false)
        activityIndicator.isHidden = true
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    @IBAction func signUpNewUser(_ sender: UIButton) {
        registerButton(enable: false)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { resul, error in
            if let error = error {
                print(error)
                
                self.registerButton(enable: true)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                return
            }
            print("Sign Up with Email")
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    private func registerButton(enable: Bool) {
        if enable {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }
    
    @objc func textFieldChanged() {
        
        guard let emailTF = emailTextField.text,
              let passwordTF = passwordTextField.text,
              let confirmPasswordTF = confirmPasswordTextField.text
        else { return }
        
        let textFieldFilled =
        !(emailTF.isEmpty) &&
        (emailTF.contains("@")) &&
        !(passwordTF.isEmpty) &&
        !(confirmPasswordTF.isEmpty) &&
        (passwordTF == confirmPasswordTF)
        
        registerButton(enable: textFieldFilled)
    }
}
