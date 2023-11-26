//
//  NetworkPerformanceView.swift
//  talkToChat
//
//  Created by Jim Ning on 11/14/23.
//

import SwiftUI
import Charts
struct DataPoint: Identifiable {
    let id: Int
    let value: Double
}


struct NetworkPerformanceView: View {
    @ObservedObject var viewModel = NetworkInputViewViewModel(tls: false)
//    @State var sendTimesArray: [TimeInterval] = []
//    @State var receiveTimesArray: [TimeInterval] = []
    var packetsSentData: [DataPoint] {
        viewModel.sendTimes.enumerated().map { DataPoint(id: $0.offset, value: $0.element) }
    }
    
    var packetsReceivedData: [DataPoint] {
        viewModel.receiveTimes.enumerated().map { DataPoint(id: $0.offset, value: $0.element) }
    }
    var body: some View {
        VStack {
            // Chart for Packets Sent
            Text("Packets Sent (Time(s) vs. Packets)")
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            Chart(packetsSentData) { dataPoint in
                LineMark(
                    x: .value("Packet Index", dataPoint.id),
                    y: .value("Time (s)", dataPoint.value)
                )
            }
            .frame(height: 200)

            // Chart for Packets Received
            Text("Packets Received (Time(s) vs. Packets)")
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()

            Chart(packetsReceivedData) { dataPoint in
                LineMark(
                    x: .value("Packet Index", dataPoint.id),
                    y: .value("Time (s)", dataPoint.value)
                )
            }
            .frame(height: 200)
        }
        .padding()
    }
}

#Preview {
    NetworkPerformanceView()
}
