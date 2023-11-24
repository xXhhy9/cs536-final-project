//
//  ChatItemView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI


struct ChatItemView: View {
    var message: ChatItem
   
    var body: some View {
        if message.isFromCurrentUser() == true{
            
            HStack{
                Spacer()
                Text(message.text).foregroundColor(.white ).padding().background(.blue).cornerRadius(16)
                Image(systemName: "person")
            }
            
            
        }
        
        
        if message.isFromCurrentUser() == false{
            HStack{
                Image(systemName: "person")
                Text(message.text).foregroundColor( .black).padding().background(.gray.opacity(0.1)).cornerRadius(16)
                Spacer()
            }
            
            
        }
    }
}
