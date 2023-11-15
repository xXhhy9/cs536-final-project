//
//  SwiftUIView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "Talk To Chat",
                           font: "Arial Rounded MT Bold",
                           angle: 15,
                           background: .blue)
                //Login Form
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TTCButton(title: "Login", background: .blue
                    ) {
                        //attempt login
                        viewModel.login()
                    }
                    .padding()
                }
                .offset(y: -50)

                
                //Register
                VStack {
                    NavigationLink("Create An Account", destination: RegisterView())
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
