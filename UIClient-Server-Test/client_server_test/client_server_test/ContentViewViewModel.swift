//
//  ContentViewViewModel.swift
//  client_server_test
//
//  Created by Jim Ning on 11/20/23.
//
import Network
import Foundation

class ContentViewViewModel: ObservableObject {
    private var connection: NWConnection?

    func startConnection(host: String, portString: String) {
        guard let port = UInt16(portString) else {
            print("Invalid port")
            return
        }

        let parameters = NWParameters(tls: NWProtocolTLS.Options())
        let tlsOptions = parameters.defaultProtocolStack.applicationProtocols.first as! NWProtocolTLS.Options
        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { _, _, _ in true }, DispatchQueue.main)
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: parameters)

        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Connected to \(host)")
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                break
            }
        }

        connection?.start(queue: .global())
    }

    func stopConnection() {
        connection?.cancel()
    }
}
