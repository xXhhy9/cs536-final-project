//
//  RegisterView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()
    init() {
        UINavigationBar.appearance().tintColor = .white
    }
    var body: some View {
        VStack {
            HeaderView(title: "Register",
                       font: "Arial Rounded MT Bold",
                       angle: -15,
                       background: .blue)
            Spacer()
            Form {
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                TTCButton(title: "Create Account", background: .blue
                ) {
                    //attempt registration
                    viewModel.register()
                }
                .padding()
            }
            .offset(y: -100)
        }
    }
}

#Preview {
    RegisterView()
}
