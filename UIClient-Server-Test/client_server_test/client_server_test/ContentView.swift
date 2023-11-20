//
//  ContentView.swift
//  client_server_test
//
//  Created by Jim Ning on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewViewModel()
    var body: some View {
        VStack {
            Form {
                TextField("IP", text: viewModel.$ip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Port", text:viewModel.$port)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
