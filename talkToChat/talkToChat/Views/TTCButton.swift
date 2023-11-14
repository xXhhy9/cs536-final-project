//
//  TTCButton.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct TTCButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    var body: some View {
        Button {
            //Action
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                Text(title)
                    .foregroundColor(.white)
                    .bold()
            }
        }
    }
}

#Preview {
    TTCButton(title: "title",
              background: .blue) {
        //Action
    }
}
