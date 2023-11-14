//
//  HeaderView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let font: String
    let angle: Double
    let background: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(background)
                .rotationEffect(Angle(degrees: angle))
            VStack {
                Text(title)
                    .font(.custom(font, size: 50))
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(.top, 80)
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 350)
        .offset(y: -150)
    }
}

#Preview {
    HeaderView(title: "Title",
               font: "Arial Rounded MT Bold",
               angle: 15,
               background: .blue)
}
