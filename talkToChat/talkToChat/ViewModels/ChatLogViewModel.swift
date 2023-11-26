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
    @Published var mockData = [ChatItem(id: UUID(), uid: "123", text: "HI THIS IS CHATGPT", createdAt: Date(), userMsg: 0),
                           ChatItem(id: UUID(), uid: "123", text: "HI THIS IS ALEX", createdAt: Date(), userMsg: 1),
                           ChatItem(id: UUID(), uid: "123", text: "UESTION", createdAt: Date(), userMsg: 0),
                           ChatItem(id: UUID(), uid: "123", text: "ANSWER", createdAt: Date(), userMsg: 0),
    
    ]
    
    // for from argument, 0 means from chatgpt and  1 means from user.
    func sendMessage(text: String, from: Int){
        
        let newMessage = ChatItem(id:UUID(), uid: "123", text: text, createdAt: Date(), userMsg: from)
        messages.append(newMessage)
        
        // all extra stuff that text to speech uses
        if newMessage.userMsg == 0{
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(identifier: "Smantha")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1
            utterance.postUtteranceDelay = 0.2
            utterance.volume = 1
            
            self.synthesizer.speak(utterance)
        }
       
        
    }
    
}
