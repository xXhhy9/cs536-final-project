//
//  User.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
