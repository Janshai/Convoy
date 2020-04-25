//
//  UserViewModel.swift
//  Convoy
//
//  Created by Jack Adams on 24/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation

class UserViewModel {
    var user: User
    var name: String {
        return user.displayName
    }
    
    
    init(user: User) {
        self.user = user
    }
    
    func sendFriendRequest() {
        UserModel.shared.sendFriendRequest(to: user)
    }
    
    func acceptFriendRequest() {
        
    }
    
    func rejectFriendRequest() {
        
    }
    
    static func searchAllUsers(for searchTerm: String, oncompletion completion: @escaping ([UserViewModel]) -> Void) {
        UserModel.shared.searchAllUsers(for: searchTerm) { result in
            switch result {
            case .success(let users):
                var userViewModels: [UserViewModel] = []
                for u in users {
                    userViewModels.append(UserViewModel(user: u))
                }
                completion(userViewModels)
            case .failure(_):
                completion([])
                //TODO: throw
            }
        }
    }
    
    
    static func getAllUsers(onCompletion completion: @escaping ([UserViewModel]) -> Void) {
        UserModel.shared.getAllUsers() { result in
            switch result {
            case .success(let users):
                var userViewModels: [UserViewModel] = []
                for u in users {
                    userViewModels.append(UserViewModel(user: u))
                }
                completion(userViewModels)
            case .failure(_):
                completion([])
                //TODO: throw
            }
        }
    }
    
    static func getFriendRequests(onCompletion completion: @escaping ([UserViewModel]) -> Void) {
        
        UserModel.shared.getFriendRequests() { result in
            switch result {
            case .success(let users):
                var userViewModels: [UserViewModel] = []
                for u in users {
                    userViewModels.append(UserViewModel(user: u))
                }
                completion(userViewModels)
                
            case .failure(_):
                completion([])
                //TODO: throw

            }
            
        }
    }
    
}

extension UserViewModel: Equatable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.user.userUID == rhs.user.userUID
    }
    
    
}


