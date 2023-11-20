//
//  NetworkInputViewViewModel.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import Foundation

class NetworkInputViewViewModel: ObservableObject {
    @Published var ip = ""
    @Published var port = ""
    @Published var errorMessage = ""
    
    init() {}
    
    func connect() {
        guard validate() else {
            return
        }
    }
    
    
    
    private func validate() -> Bool {
        errorMessage = ""
        guard !ip.trimmingCharacters(in: .whitespaces).isEmpty,
              !ip.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        guard ip.contains(".") && ip.count != 15 else {
            errorMessage = "Please enter valid ip"
            return false
        }
        let intValue = Int(port) ?? -1
        guard intValue < 0 else {
            errorMessage = "Please enter a valid port"
            return false
        }
        return true
    }
}
