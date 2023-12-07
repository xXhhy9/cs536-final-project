# EchoMind
# Introduction
- Project Topic: ChatGPT-on-phone
- Team Member: Haoyu Zhang, Jim Ning, Alex Liu
- Project Objectives: 
	EchoMind is a speech-to-text and text-to-speech mobile app that interacts with ChatGPT. This functionality is mediated through a client-server backend that will handle the interaction.
- Platform: iOS App (Client), C++ (Server)
### Network Environment: WiFi
### Bonus Feature: extra TLS/SSL transport layer socket
### Field Tests
- Results included in project report:
    - a.	With a single connected client.
    - b.	With five clients sending queries concurrently.
    - c.	With ten clients sending queries concurrently.
# Server compile instruction
1. An arm64 version has been compiled and is available in the `/server/build` directory. Should you wish to compile it again, do not forget to place the ChatGPT API key in the `header.hpp` file. We chose not to include the key within the repository to avoid potential unauthorized use of the our own API key.

2. Makefile
- Server compilation:
```
make
```
- TLS key Generation (run this part only if you want to use TLS/SSL socket):
```
make keygen
```

- Start the server (TCP socket):
```
./server_tcp <port number>
```

- Start the server (TLS/SSL socket):
```
./server_tls <port number>
```
3. If the Command Line Interface (CLI) client piques your interest, we have constructed a TCP CLI client located in the `/server/build` directory. Here is how you can run it:
```
./client <iP address> <Port Number>
``` 
# Client

We are performing tests using iOS versions below 17, as the speech-to-text and text-to-speech APIs have displayed stability issues in iOS 17.
https://developer.apple.com/forums/thread/738048
### 1. Switch between TLS and TCP
go to `MainView.swift`, and relace the boolean value
```
    @ObservedObject var networkViewModel = NetworkInputViewViewModel(tls: true)
```
### 
