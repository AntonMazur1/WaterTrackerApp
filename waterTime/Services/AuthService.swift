//
//  AuthService.swift
//  waterTime
//
//  Created by Клоун on 11.09.2022.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import GoogleSignIn
import UIKit

class AuthService {
    static let shared = AuthService()
    
    private var userProfile: User?
    
    init() {}
    
    //MARK: Custom Login
    func loginIntoApp(email: String, password: String, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(result))
        }
    }
    
    //MARK: Google Login
    @objc func googleSignIn(_ presentVC: UIViewController, completion: @escaping () -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentVC) { user, error in

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
          else { return }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error)
                    return
                }
                completion()
                print("Successfully logged in Firebase")
            }
        }
    }
    
    //MARK: Facebook Login
    func fetchingFacebookFields() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"id, name, email"])
        request.start() { connection, result, error in
            if let result = result as? [String: Any], error == nil {
                self.userProfile = User(data: result)
                print("fetched user: \(self.userProfile?.name ?? "")")
            }
            self.saveIntoFirebase()
        }
    }
    
    func handleFBLogin() {
        let manager = LoginManager()
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        manager.logIn(permissions: ["email", "public_profile"], from: loginVC) { [unowned self] result, error in
            if let error = error {
                print(error)
            }
            
            guard let result = result else { return }
            
            if result.isCancelled {
                return
            }
            
            signIntoFirebase()
        }
    }
    
    //MARK: Firebase Login
    func saveIntoFirebase(completion: (() -> Void)? = nil) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name,"email": userProfile?.email]
        let values = [uid: userData]
        
        Database.database().reference().child("Users").updateChildValues(values) { error, _ in
            if let error = error {
                print(error)
                return
            }
            completion?()
            print("User saved")
        }
    }
    
    func signIntoFirebase() {
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
    
    func checkForLogin(completion: @escaping (LoginViewController) -> Void) {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                completion(loginVC)
            }
        }
    }
    
    func loginButton(_ error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard Auth.auth().currentUser != nil else { return }
        
        signIntoFirebase()
    }
}
