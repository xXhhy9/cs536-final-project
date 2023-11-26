# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -std=c++11 -I /opt/homebrew/Cellar/nlohmann-json/3.11.2/include -I/opt/homebrew/Cellar/openssl@3/3.1.4/include -L/opt/homebrew/Cellar/openssl@3/3.1.4/lib -lssl -lcrypto

# Linker flags
LDFLAGS = -pthread -lcurl

# Server Source File
SERVER_SRC = sampleserver.cpp chatgpt.cpp socket.cpp tcp.cpp tls.cpp

# Targets
all: server_notls client

server_tls:
	$(CXX) $(CXXFLAGS) -D USE_TLS $(SERVER_SRC) -o server $(LDFLAGS)

server_notls:
	$(CXX) $(CXXFLAGS) $(SERVER_SRC) -o server $(LDFLAGS)

client: sampleClient.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@

clean:
	rm -f server client
