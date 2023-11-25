//
//  ContentViewViewModel.swift
//  client_server_test
//
//  Created by Jim Ning on 11/20/23.
//
import Network
import Foundation
import Security

class NetworkInputViewViewModel: ObservableObject {
    private var connection: NWConnection?
    @Published var isConnected: Bool = false
    func startConnection(host: String, portString: String) {
        guard let port = UInt16(portString) else {
            print("Invalid port")
            return
        }

        let parameters = NWParameters(tls: NWProtocolTLS.Options())
        let tlsOptions = parameters.defaultProtocolStack.applicationProtocols.first as! NWProtocolTLS.Options
                sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { sec_protocol_metadata, sec_trust, sec_protocol_verify_complete in
                    
                    // Load the local certificate
                    guard let localCertificate = self.loadCertificate(named: "certificate") else {
                        sec_protocol_verify_complete(false)
                        return
                    }

                    // Evaluate the server's trust and compare it with the local certificate
                    let serverCertificatesMatch = self.evaluateServerTrust(sec_trust, against: localCertificate)
                    sec_protocol_verify_complete(serverCertificatesMatch)

                }, DispatchQueue.main)

        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: parameters)

        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Connected to \(host)")
                DispatchQueue.main.async {
                    self.isConnected = true
                }
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                print("state: \(state)")
                break
            }
        }
        connection?.start(queue: .global())
    }
    func evaluateServerTrust(_ serverTrust: sec_trust_t, against localCertificate: SecCertificate) -> Bool {
        // Implement the logic to evaluate the server's trust object against your local certificate
        // This might involve comparing the public keys, certificate data, etc.
        return true // return true if the server's certificate matches the local certificate
    }
    func loadCertificate(named name: String) -> SecCertificate? {
        let fullPath = "/Users/ningj2413/Desktop/CS536/Final Project/cs536-final-project/talkToChat/talkToChat/Other/\(name).cer" // Use the absolute path
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) else {
            return nil
        }

        return SecCertificateCreateWithData(nil, data as CFData)
    }

    func sendMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else {
            print("Error: Unable to encode message to Data")
            return
        }

        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Error: Message sending failed with error \(error)")
                return
            }
            print("Message successfully sent")
        }))
    }

    func stopConnection() {
        connection?.cancel()
    }
}
