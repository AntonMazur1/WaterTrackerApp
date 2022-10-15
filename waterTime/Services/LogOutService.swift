//
//  LogOutService.swift
//  waterTime
//
//  Created by Клоун on 14.09.2022.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class LogOutService {
    static let shared = LogOutService()
    
    init() {}
    
    func openLoginVC(completion: @escaping (LoginViewController) -> Void) {
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                completion(loginVC)
                return
            }
        } catch {
            print(error)
        }
    }
    
    func signOutFromProvider(completion: () -> Void) {
        if let providerData = Auth.auth().currentUser?.providerData {
            for user in providerData {
                switch user.providerID {
                case "facebook.com":
                    let loginManager = LoginManager()
                    loginManager.logOut()
                    completion()
                    print("User Successfully Log Out From Facebook")
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("User Successfully Log Out From Google")
                    completion()
                case "password":
                    try! Auth.auth().signOut()
                    print("User Successfully Log Out From Email")
                    completion()
                default:
                    print("Unknown Provider: \(user.providerID)")
                }
            }
        }
    }
}
