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
    
    func acceptFriendRequest(oncompletion completion: @escaping () -> Void) {
        UserModel.shared.updateFriendRequestStatus(to: "accepted", for: user.userUID) {
            completion()
        }
    }
    
    func rejectFriendRequest(oncompletion completion: @escaping () -> Void) {
        UserModel.shared.updateFriendRequestStatus(to: "rejected", for: user.userUID) {
            completion()
        }
    }
    
    static func searchAllUsers(for searchTerm: String, oncompletion completion: @escaping ([UserViewModel]) -> Void) {
        UserModel.shared.searchAllUsers(for: searchTerm) { result in
            completion(unwrapUsers(from: result))
        }
    }
    
    
    static func getAllUsers(onCompletion completion: @escaping ([UserViewModel]) -> Void) {
        UserModel.shared.getAllUsers() { result in
            completion(unwrapUsers(from: result))
        }
    }
    
    static func getFriendRequests(onCompletion completion: @escaping ([UserViewModel]) -> Void) {
        
        UserModel.shared.getFriendRequests() { result in
            completion(unwrapUsers(from: result))
            
        }
    }
    
    static func getFriends(onCompletion completion: @escaping ([UserViewModel]) -> Void) {
        
        UserModel.shared.getFriends() { result in
            completion(unwrapUsers(from: result))
        }
        
    }
    
    static func searchFriends(for searchTerm: String, oncompletion completion: @escaping ([UserViewModel]) -> Void) {
        
        UserModel.shared.searchFriendRequests(for: searchTerm) { result in
            completion(unwrapUsers(from: result))
        }
        
    }
    
    private static func unwrapUsers(from result: Result<[User], Error>) -> [UserViewModel] {
        switch result {
        case .success(let users):
            var userViewModels: [UserViewModel] = []
            for u in users {
                userViewModels.append(UserViewModel(user: u))
            }
            return userViewModels
            
        case .failure(_):
            return []
            //TODO: throw

        }
    }
    
}

extension UserViewModel: Equatable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.user.userUID == rhs.user.userUID
    }
    
    
}


