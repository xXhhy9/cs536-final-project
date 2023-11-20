//
//  ContentViewViewModel.swift
//  client_server_test
//
//  Created by Jim Ning on 11/20/23.
//
import Network
import Foundation
import Security

class ContentViewViewModel: ObservableObject {
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
        guard let url = Bundle.main.url(forResource: name, withExtension: "cer"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }

        return SecCertificateCreateWithData(nil, data as CFData)
    }
    func stopConnection() {
        connection?.cancel()
    }
}