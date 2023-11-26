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
        if message.userMsg == 1{
            
            HStack{
                Spacer()
                Text(message.text).foregroundColor(.white ).padding().background(.blue).cornerRadius(16)
                Image(systemName: "person")
            }
            
            
        }
        
        
        if message.userMsg == 0{
            HStack{
                Image(systemName: "cloud")
                Text(message.text).foregroundColor( .black).padding().background(.gray.opacity(0.1)).cornerRadius(16)
                Spacer()
            }
            
            
        }
    }
}
