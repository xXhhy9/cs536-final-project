//
//  ContentView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    @ObservedObject var networkViewModel = NetworkInputViewViewModel(tls: false)
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            //signed in
            TabView {
                NetworkInputView(viewModel: networkViewModel)
                    .tabItem {
                        Label("Network Settings", systemImage: "gear")
                    }
                NetworkPerformanceView(viewModel: networkViewModel)
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
