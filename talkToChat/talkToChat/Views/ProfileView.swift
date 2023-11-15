//
//  ProfileView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    var body: some View {
        NavigationView {
            VStack {
                //Sign Out
                Button("Log Out") {
                    viewModel.logOut()
                }
                .tint(.red)
                .padding()
            }
            .navigationTitle("Profile")
            
        }
    }
}

#Preview {
    ProfileView()
}
