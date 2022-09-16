//
//  UserModel.swift
//  waterTime
//
//  Created by Клоун on 31.05.2022.
//

import Foundation

struct User {
    let name: String?
    let email: String?
    let id: Int?
    
    init(data: [String: Any]) {
        let id = data["id"] as? Int
        let name = data["name"] as? String
        let email = data["email"] as? String
        
        self.name = name
        self.email = email
        self.id = id
    }
}
