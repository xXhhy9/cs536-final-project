//
//  ProfileViewViewModel.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import FirebaseAuth
import Foundation

class ProfileViewViewModel: ObservableObject {
    init() {}
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
