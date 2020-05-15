//
//  AuthService.swift
//  Convoy
//
//  Created by Jack Adams on 12/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
protocol AuthService {
    var currentUser: User? { get }
}
