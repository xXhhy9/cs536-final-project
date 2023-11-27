# cs536-final-project (Server)

## Compile Instruction
- Note: The current version was tested and ran on ARM64 machines (ie. M1 & M2 macbook).
- Server compilation:
```
make
```
- TLS key Generation:
```
make keygen
```

- Start the server (tcp):
```
./server_tcp <port number>
```

- Start the server (tls):
```
./server_tls <port number>
```