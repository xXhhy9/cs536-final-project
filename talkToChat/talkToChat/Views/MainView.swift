//
//  ContentView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            //signed in
            TabView {
                NetworkInputView()
                    .tabItem {
                        Label("Network Settings", systemImage: "gear")
                    }
                ChatLogView()
                    .tabItem {
                        Label("Chat", systemImage: "house")
                    }
                NetworkPerformanceView()
                    .tabItem {
                        Label("Network Performance", systemImage:
                                "gear")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage:
                                "person.circle")
                    }
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    MainView()
}
