//
//  ChatItem.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import Foundation
struct ChatItem : Decodable, Identifiable {
    let id: UUID
    let uid: String
    let text: String
    let createdAt: Date
    
    func isFromCurrentUser() -> Bool{
        return false
    }
}
