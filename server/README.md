# cs536-final-project (Server)

# Server compile instruction
1. An arm64 version has been compiled and is available in the `/server/build` directory. Should you wish to compile it again, do not forget to place the ChatGPT API key in the `header.hpp` file.

2. Libraries
- Install the curl and openssl libraries: Depending on your Linux distribution, install curl and openssl dev libraries. For Ubuntu/Debian you would do:
```
sudo apt-get update
sudo apt-get install libcurl4-openssl-dev libssl-dev
```
- On macOS you would do:
```
brew install nlohmann-json
brew install curl openssl
```
3. Makefile
- Server compilation:
```
make -f Makefile-arm64-macOS

or 

make -f Makefile-x86-linux
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
./client <IP address> <Port Number>
``` 