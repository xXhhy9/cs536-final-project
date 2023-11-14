//
//  talkToChatApp.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI
import FirebaseCore



@main
struct talkToChatApp: App {
    init() {
        FirebaseApp.configure()
        UINavigationBar.appearance().tintColor = .white
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
