//
//  ContentViewViewModel.swift
//  client_server_test
//
//  Created by Jim Ning on 11/20/23.
//
import NIO
import Foundation

class ContentViewViewModel: ObservableObject {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let channel: Channel?
    @Published var ip: String
    @Published var port
    
    init() {}
    
    func connect(host: String, port: Int) {
        do {
            let boostrap = ClientBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { channel in
                    channel.pipline.addHandler(MyDataHandler())
                }
            channel = try bootstrap.connect(host: host, port: port).wait()
        } catch {
            print("Failed to connect: \(error)")
        }
    }
    
    func disconnect() {
        do {
            try channel?.close().wait()
        } catch {
            print("Error occurred while closing channel :\(error)")
        }
    }
}
class MyDataHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var byteBuffer = self.unwrapInboundIn(data)
        if let receivedString = byteBuffer.readString(length: byteBuffer.readableBytes) {
            print("Received: \(receivedString)")
        }
    }
}
