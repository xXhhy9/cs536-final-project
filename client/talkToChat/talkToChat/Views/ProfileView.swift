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
           
            VStack{
                if let user = viewModel.user{
                    
                    
                    
                    Form{
                        Group{
                            VStack{
                                HStack{
                                    Spacer()
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .padding()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(Color.blue)
                                        .frame(width: 125, height: 125)
                                    Spacer()
                                }
                                Text("UserID: \(user.id) ")
                            }
                            
                        }
                        Section(header: Text("Personal Info")){
                            HStack{
                                Text("Name: ").bold()
                                Text(user.name)
                            }
                            
                            HStack{
                                Text("Email: ").bold()
                                Text(user.email)
                            }
                            
                            HStack{
                                Text("Member Since: ").bold()
                                Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
                            }
                        }
            
                    
                        //Sign Out
                       
                    }
                   
                    
                    HStack{
                        Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.red, lineWidth: 3).frame(width: 300, height: 50) // Adjust the color as needed
                            
                            Button("Log Out") {
                                viewModel.logOut()
                            }
                            .tint(.red)
                            .padding()
                        }
                        Spacer()
                    }.padding()
                    
                    
                } else{
                    Text("Loading Profile...")
                   
                }
                
            }.navigationTitle("Profile")
            
            
        }.onAppear{
            viewModel.fetchUser()
        }
    }

}

#Preview {
    ProfileView()
}
