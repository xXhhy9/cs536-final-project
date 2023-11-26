//
//  ContentViewViewModel.swift
//  client_server_test
//
//  Created by Jim Ning on 11/20/23.
//

import Foundation
import Network
import Security

class NetworkInputViewViewModel: ObservableObject {
    private var connection: NWConnection?
    private var tlsEnabled: Bool
    @Published var isConnected: Bool = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var gptResponse = ""
    @Published var sendTimes: [TimeInterval] = []
    @Published var receiveTimes: [TimeInterval] = []
    init(tls: Bool) {
        self.tlsEnabled = tls
    }

    func startConnection(host: String, portString: String) {
        errorMessage = ""
        successMessage = ""
        guard !host.trimmingCharacters(in: .whitespaces).isEmpty,
              !portString.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        guard let port = UInt16(portString) else {
            errorMessage = "Invalid Port"
            return
        }
        let parameters: NWParameters
        if tlsEnabled {
            parameters = NWParameters(tls: NWProtocolTLS.Options())
            configureTLS(parameters: parameters)
        } else {
            parameters = NWParameters.tcp
        }

        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: parameters)

        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.successMessage = "Connected to \(host)"
                DispatchQueue.main.async {
                    self?.isConnected = true
                }
                //self?.receiveData()
//                self?.promptAndSend()
            case .failed(let error):
                self?.errorMessage = "Failed to connect: \(error)"
                exit(1)
            default:
                break
            }
        }

        connection?.start(queue: .global())
    }

    private func configureTLS(parameters: NWParameters) {
        let tlsOptions = parameters.defaultProtocolStack.applicationProtocols.first as! NWProtocolTLS.Options

        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { sec_protocol_metadata, sec_trust, sec_protocol_verify_complete in
            print("Inside verify block...") // Debug print

            guard let localCertificate = self.loadCertificate(named: "certificate") else {
                print("Failed to load local certificate...") // Debug print
                sec_protocol_verify_complete(false)
                self.stopConnection()
                return
            }

            print("Local certificate loaded successfully...") // Debug print

            let serverCertificatesMatch = self.evaluateServerTrust(sec_trust, against: localCertificate)
            sec_protocol_verify_complete(serverCertificatesMatch)
        }, DispatchQueue.main)
    }

    func evaluateServerTrust(_ serverTrust: sec_trust_t, against localCertificate: SecCertificate) -> Bool {
        // Implement your logic here
        return true // Temporarily returning true for simplicity
    }

    func loadCertificate(named name: String) -> SecCertificate? {
        let fullPath = "/Users/ningj2413/Desktop/CS536/Final Project/cs536-final-project/talkToChat/talkToChat/Other/certificate.cer" // Use the absolute path
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) else {
            return nil
        }

        return SecCertificateCreateWithData(nil, data as CFData)
    }

    // Client Operations
    func promptAndSend(input: String) {
//        print("Enter query: ", terminator: "")
        let query = input
        if query != "exit" {
            sendData(Data(query.utf8))
        } else {
            stopConnection()
        }
    }

    func sendData (_ data: Data) {
        let time1 = Date()
        connection?.send(content: data, completion: .contentProcessed({ [weak self] error in
            if let error = error {
                print("Send error: \(error)")
                return
            }
            print("Data sent successfully.")
            let time2 = Date()
            let difference = time2.timeIntervalSince(time1)
            
            DispatchQueue.main.async {
                self?.sendTimes.append(difference)
            }

           self?.receiveData()
        }))
    }

    func receiveData() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in
            let time1 = Date()
            guard let data = data, !data.isEmpty else {
                print("No data received or connection closed.")
                self?.stopConnection()
                return
            }

            if let message = String(data: data, encoding: .utf8) {
                print("Received message: \(message)")
                self?.gptResponse = message
                let time2 = Date()
                let difference = time2.timeIntervalSince(time1)
                DispatchQueue.main.async {
                    self?.receiveTimes.append(difference)
                }
            }
            if isComplete || error != nil {
                self?.stopConnection()
            } 
//            else {
//                self?.promptAndSend(input:
//            }
        }
    }
    func stopConnection() {
        print("Disconnecting...")
        connection?.cancel()
        exit(0)
    }
}
