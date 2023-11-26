//
//  ChatItem.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import Foundation

// There are lots of fields in this struct however only text, createdAt, and userMsg matter. You can use the other fields if necessary.
// userMsg = 1 when user sends message, userMsg = 0 when chatgpt sends message.
struct ChatItem : Decodable, Identifiable {
    let id: UUID
    let uid: String
    let text: String
    let createdAt: Date
    let userMsg: Int
    
}
