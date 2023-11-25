//
//  ContentView.swift
//  client_server_test
//
//  Created by Jim Ning on 11/16/23.
//

import SwiftUI
import Foundation

struct NetworkInputView: View {
    @State private var host = ""
    @State private var port = ""
    @State private var isLoading = false
    @ObservedObject var viewModel = NetworkInputViewViewModel()
    @State private var errorMessage = ""
    var body: some View {
        VStack {
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(Color.red).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        errorMessage = ""
                    }
                }
            }
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage).foregroundColor(Color.red).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                    }
                }
            }
            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage).foregroundColor(Color.green).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        host = ""
                        port = ""
//                        viewModel.successMessage = ""
                    }
                }
            } else {
                TextField("Enter Host", text: $host)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Enter Port", text: $port)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                if isLoading {
                      ProgressView("Connecting...")
                          .onAppear {
                              DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                  isLoading = false
                                  if !viewModel.isConnected {
                                      // Show error message
                                      errorMessage = "Could not connect to \(host)"
                                  }
                              }
                          }
                } else {
                    Button("Connect") {
                        viewModel.startConnection(host: host, portString: port)
                        isLoading = true
                    }
                    .padding()
               }
            }
            if viewModel.isConnected {
                ChatLogView(viewModel: viewModel)
            }
            
//            Button("Send Message") {
//                if viewModel.isConnected {
//                    viewModel.sendMessage("Hello12345")
//                } else {
//                    print("Not Connected")
//                }
//            }
//            .padding()

        }
    }
}


#Preview {
    NetworkInputView()
}
