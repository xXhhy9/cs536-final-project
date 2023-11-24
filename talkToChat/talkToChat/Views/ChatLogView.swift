//
//  ChatLogView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI



struct ChatLogView: View{
    @StateObject var chatLogViewModel = ChatLogViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State var text = ""
    var body: some View{
        VStack{
            ScrollView(showsIndicators: false){
                VStack(spacing: 10){
                    ForEach(chatLogViewModel.messages){ message in
                        ChatItemView(message: message)
                        
                    }
                }
                
            }
            HStack{
                TextField("Ask me anything.", text: $text, axis:.vertical).padding().background(Color(uiColor: .systemGray6)).cornerRadius(18)
                Button{
                    if isRecording == false {
                        startScrum()
                        isRecording = true
                    } else {
                        text = endScrum()
                        isRecording = false
                    }
                } label: {
                    if isRecording == false {
                        Image(systemName: "mic.circle")  .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: "mic.circle.fill")  .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    
                    
                }
                Button{
                    if text.count > 2 {
                        chatLogViewModel.sendMessage(text: text)
                        text = ""
                    }
                   
                } label: {
                    Text("Send").padding().background(.blue).foregroundColor(.white).cornerRadius(18)
                }.padding([.bottom, .top, .trailing])
            }
            
        }
        
    }
    private func startScrum() {
    
            
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
     
    }
    
    private func endScrum() -> String {
        
        speechRecognizer.stopTranscribing()
        isRecording = false
        return speechRecognizer.transcript
      
    }
}
//struct ChatLogView: View {
//    @State var chatMessages: [ChatMessage] = ChatMessage.sampleMessages
//    @State var messageText: String = ""
//    var body: some View {
//        VStack{
//            ScrollView{
//                LazyVStack{
//                    ForEach(chatMessages, id: \.id){ message in
//                        messageView(message: message)
//                    }
//                }
//            }
//            HStack{
//                TextField("Enter a message", text: $messageText).padding().background(.gray.opacity(0.1)).cornerRadius(12)
//                Button{} label: {
//                    Text("Send").foregroundColor(.white).padding().background(.black).cornerRadius(12)
//                }
//            }
//        }.padding()
//        
//        
//    }
//    
//    func messageView(message: ChatMessage) -> some View{
//        HStack{
//            if message.sender == .user{
//                Spacer()
//                Text(message.content).foregroundColor(message.sender == .user ? .white : .black).padding().background(message.sender == .user ? .blue : .gray.opacity(0.1)).cornerRadius(16)
//                Circle().frame(width:40)
//                
//            }
//            
//            
//            if message.sender == .chatgpt{
//                HStack{
//                    Circle().frame(width:40)
//                    Text(message.content).foregroundColor(message.sender == .user ? .white : .black).padding().background(message.sender == .user ? .blue : .gray.opacity(0.1)).cornerRadius(16)
//                }
//                
//                Spacer()
//            }
//        }
//        
//    }
//}
//
//struct ChatMessage {
//    let id: String
//    let content: String
//    let date: Date
//    let sender: MessageSender
//}
//enum MessageSender{
//    case user
//    case chatgpt
//}
//
//extension ChatMessage{
//    static let sampleMessages = [
//    ChatMessage(id: UUID().uuidString, content: "Hello, this is chatgpt. Ask me anything!", date: Date(), sender: .chatgpt),
//     ChatMessage(id: UUID().uuidString, content: "QUESTION", date: Date(), sender: .user),
//    ChatMessage(id: UUID().uuidString, content: "RESPONCE", date: Date(), sender: .chatgpt)
//    ]
//}
//#Preview {
//    ChatLogView()
//}
