//
//  ContentView.swift
//  client_server_test
//
//  Created by Jim Ning on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var host = ""
    @State private var port = ""
    @ObservedObject var viewModel = ContentViewViewModel()

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
        }
    }
}


#Preview {
    ContentView()
}
