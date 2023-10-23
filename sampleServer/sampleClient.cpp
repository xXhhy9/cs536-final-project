/**
 * @file
 * @author
 * - Haoyu Zhang
 */
#include <arpa/inet.h>
#include <iostream>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <sstream>


using namespace std;

int main(int argc, char const* argv[]) {
    int clientSocket, client_fd = 0;

    if (argc != 3) {
		fprintf(stderr, "Usage: ./sampleClient server_ip server_port\n");
		return -1;
	}

    if ((clientSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		printf("\n Socket creation error \n");
		return -1;
	}

    int PORT = atoi(argv[2]);
    struct sockaddr_in serverAddress;
    memset(&serverAddress, 0, sizeof(serverAddress));
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(PORT);
    if (inet_pton(AF_INET, argv[1], &serverAddress.sin_addr) <= 0) {
        fprintf(stderr, "ip address error\n");
		return -1;
    }

    if (connect(clientSocket, (struct sockaddr*)&serverAddress, sizeof(serverAddress)) < 0) {
        perror("Connection Failed");
        return -1;
    }


    while (true) {
        cout << "Enter query: ";
        string query;
        getline(cin, query);
        if (query == "exit") break;
        write(clientSocket, query.c_str(), query.size());

        char buffer[256];
        std::stringstream ss;

        while (true) {
            memset(buffer, 0, sizeof(buffer));
            ssize_t bytes_received = read(clientSocket, buffer, sizeof(buffer) - 1);
            if (bytes_received <= 0) {
                break;
            }
            ss.write(buffer, bytes_received);
            printf("%d\n", buffer[bytes_received - 1]);
            if (buffer[bytes_received - 1] == '\n' || buffer[bytes_received - 1] == '\0') {
                break;
            }
        }

        std::string response = ss.str();
        cout << "Server response: " << response << endl;
        cout.flush();
    }

    cout << "disconnecting......" << endl;
    close(clientSocket);
    return 0;
}
