//
//  ChatLogView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct ChatLogView: View {
    @State var chatMessages: [ChatMessage] = ChatMessage.sampleMessages
    @State var messageText: String = ""
    @ObservedObject var viewModel = NetworkInputViewViewModel()
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(chatMessages, id: \.id){ message in
                        messageView(message: message)
                    }
                }
            }
            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage)
            }
            HStack{
                TextField("Enter a message", text: $messageText).padding().background(.gray.opacity(0.1)).cornerRadius(12)
                Button{} label: {
                    Text("Send").foregroundColor(.white).padding().background(.black).cornerRadius(12)
                }
            }
        }.padding()
        
        
    }
    
    func messageView(message: ChatMessage) -> some View{
        HStack{
            if message.sender == .user{
                Spacer()
                Text(message.content).foregroundColor(message.sender == .user ? .white : .black).padding().background(message.sender == .user ? .blue : .gray.opacity(0.1)).cornerRadius(16)
                Circle().frame(width:40)
                
            }
            
            
            if message.sender == .chatgpt{
                HStack{
                    Circle().frame(width:40)
                    Text(message.content).foregroundColor(message.sender == .user ? .white : .black).padding().background(message.sender == .user ? .blue : .gray.opacity(0.1)).cornerRadius(16)
                }
                
                Spacer()
            }
        }
        
    }
}

struct ChatMessage {
    let id: String
    let content: String
    let date: Date
    let sender: MessageSender
}
enum MessageSender{
    case user
    case chatgpt
}

extension ChatMessage{
    static let sampleMessages = [
    ChatMessage(id: UUID().uuidString, content: "Hello, this is chatgpt. Ask me anything!", date: Date(), sender: .chatgpt),
     ChatMessage(id: UUID().uuidString, content: "QUESTION", date: Date(), sender: .user),
    ChatMessage(id: UUID().uuidString, content: "RESPONCE", date: Date(), sender: .chatgpt)
    ]
}
#Preview {
    ChatLogView()
}
