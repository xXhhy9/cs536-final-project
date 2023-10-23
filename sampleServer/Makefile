# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -std=c++11 -I /opt/homebrew/Cellar/nlohmann-json/3.11.2/include

# Linker flags
LDFLAGS = -pthread -lcurl

# Targets
all: server client

server: sampleServer.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

client: sampleClient.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@

clean:
	rm -f server client
