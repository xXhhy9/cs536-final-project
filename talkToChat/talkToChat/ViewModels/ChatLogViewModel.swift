//
//  ChatLogViewModel.swift
//  talkToChat
//
//  Created by Alex Liu on 11/23/23.
//
import SwiftUI
import Foundation
import AVFoundation
class ChatLogViewModel: ObservableObject{
    let synthesizer = AVSpeechSynthesizer()
    
    @Published var messages = [ChatItem]()
    @Published var mockData = [ChatItem(id: UUID(), uid: "123", text: "HI THIS IS CHATGPT", createdAt: Date()),
                           ChatItem(id: UUID(), uid: "123", text: "HI THIS IS ALEX", createdAt: Date()),
                           ChatItem(id: UUID(), uid: "123", text: "UESTION", createdAt: Date()),
                           ChatItem(id: UUID(), uid: "123", text: "ANSWER", createdAt: Date()),
    
    ]
    
    func sendMessage(text: String){
        
        let newMessage = ChatItem(id:UUID(), uid: "123", text: text, createdAt: Date())
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "Smantha")
        utterance.rate = 0.57
        utterance.pitchMultiplier = 1
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1
        
        self.synthesizer.speak(utterance)
        messages.append(newMessage)
    }
    
}
