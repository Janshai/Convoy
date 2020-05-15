//
//  FirebaseAuthService.swift
//  Convoy
//
//  Created by Jack Adams on 12/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService: AuthService {
    var currentUser: User? {
        let user = Auth.auth().currentUser
        if let user = user {
            return User(displayName: user.displayName!, email: user.email!, userUID: user.uid)
        } else {
            return nil
        }
    }
    
    
}
