//
//  ChatLogView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI



struct ChatLogView: View{
    // ChatLogViewModel which stores all the messages for convo between user and chatgpt.
    @StateObject var chatLogViewModel = ChatLogViewModel()
    // speechRecognizer is the audio workings behind the
    @StateObject var speechRecognizer = SpeechRecognizer()
    // variable keeps track whether to record or not. toggled based on microphone button.
    @State private var isRecording = false
    // this is the text that is in the textfield
    @State var text = ""
    
    @ObservedObject var viewModel = NetworkInputViewViewModel(tls: false)
    
    var body: some View{
        VStack{
            ScrollView(showsIndicators: false){
                VStack(spacing: 10){
                    ForEach(chatLogViewModel.messages){ message in
                        ChatItemView(message: message)
                        
                    }
                }
                
            }

            if !viewModel.gptResponse.isEmpty {
                Text("").foregroundColor(Color.red).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        chatLogViewModel.sendMessage(text: viewModel.gptResponse, from: 0)
                        viewModel.gptResponse = ""
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
                    // request will not send if less than two characters
                    if text.count > 2 {
                        // this is the message that the uesr sends with from value as 1
                        chatLogViewModel.sendMessage(text: text, from: 1)
                        viewModel.receiveData()
                        viewModel.promptAndSend(input: text)
                        text = ""
                        // this is the holder message that chatgpt will respond with with from value as 0
//                        chatLogViewModel.sendMessage(text: viewModel.gptResponse, from: 0)
//                        viewModel.gptResponse = ""
                    }
                   
                } label: {
                    Text("Send").padding().background(.blue).foregroundColor(.white).cornerRadius(18)
                }.padding([.bottom, .top])
            }
            
        }.padding()
        
    }
    private func startScrum() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
     
    }
    
    private func endScrum() -> String {
        speechRecognizer.stopTranscribing()
        isRecording = false
        // speechRecognizer.transcript is the text collected through the users recording.
        return speechRecognizer.transcript
    }
}
