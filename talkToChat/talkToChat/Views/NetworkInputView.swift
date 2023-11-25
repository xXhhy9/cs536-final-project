//
//  ContentView.swift
//  client_server_test
//
//  Created by Jim Ning on 11/16/23.
//

import SwiftUI

struct NetworkInputView: View {
    @State private var host = ""
    @State private var port = ""
    @ObservedObject var viewModel = NetworkInputViewViewModel()

    var body: some View {
        VStack {
            TextField("Enter Host", text: $host)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter Port", text: $port)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()

            Button("Connect") {
                viewModel.startConnection(host: host, portString: port)
            }
            .padding()
            Button("Send Message") {
                if viewModel.isConnected {
                    viewModel.sendMessage("Hello12345")
                } else {
                    print("Not Connected")
                }            }
            .padding()

            
//            NavigationLink(destination: ConnectedView(), isActive: $viewModel.isConnected) {
//                EmptyView()
//            }
        }
    }
}


#Preview {
    NetworkInputView()
}
