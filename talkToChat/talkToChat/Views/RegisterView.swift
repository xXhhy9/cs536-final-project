//
//  RegisterView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct RegisterView: View {
    @State var name = ""
    @State var email = ""
    @State var password = ""
    var body: some View {
        VStack {
            HeaderView(title: "Register",
                       font: "Arial Rounded MT Bold",
                       angle: -15,
                       background: .blue)
            Spacer()
            Form {
                TextField("Full Name", text: $name)
                    .textFieldStyle(DefaultTextFieldStyle())
                TextField("Email", text: $email)
                    .textFieldStyle(DefaultTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(DefaultTextFieldStyle())
                TTCButton(title: "Create Account", background: .blue
                ) {
                    //attempt registration
                }
            }
            .offset(y: -100)
        }
    }
}

#Preview {
    RegisterView()
}
