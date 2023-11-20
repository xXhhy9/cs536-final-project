//
//  NetworkInputView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct NetworkInputView: View {
    @StateObject var viewModel = NetworkInputViewViewModel()
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "Connection",
                           font: "Arial Rounded MT Bold",
                           angle: 0,
                           background: .black)
                .offset(y: -10)
                
                //Login Form
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    TextField("IP", text: $viewModel.ip)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    SecureField("Port", text: $viewModel.port)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TTCButton(title: "Connect", background: .blue
                    ) {
                        //attempt connection
                        viewModel.connect()
                    }
                    .padding()
                }
                .offset(y: -50)

                Spacer()
            }
        }
        .accentColor(.white)
    }
}

#Preview {
    NetworkInputView()
}
