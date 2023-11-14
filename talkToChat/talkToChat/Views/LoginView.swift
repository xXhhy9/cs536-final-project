//
//  SwiftUIView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
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
                    TextField("Email Address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle());
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle());
                    TTCButton(title: "Login", background: .blue
                    ) {
                        //attempt login
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
