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
#include <fstream>


using namespace std;

struct MessageHeader {
    int type;  // 1 for text, 2 for audio
    int length;  // length of the following message
};

int main(int argc, char const* argv[]) {
    int clientSocket;

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
        cout << "Choose an option:\n1. Send Text\n2. Send Audio\n3. Exit\n";
        int choice;
        cin >> choice;

        stringstream ss;
        if (choice == 1) {
            // Text query
            cout << "Enter query: ";
            string query;
            getline(cin, query);
            if (query == "exit") break;
            // Step 1: send request header
            MessageHeader header{1, (int)query.size()};
            write(clientSocket, &header, sizeof(header));

            // Step 2: send query
            write(clientSocket, query.c_str(), query.size());

        } else if (choice == 2) {
            //audio file 
            ifstream audioFile("<Replace with audio file directory>", ios::binary | ios::ate);
            streamsize size = audioFile.tellg();
            audioFile.seekg(0, ios::beg);

            char* buffer = new char[size];
            if (audioFile.read(buffer, size)) {
                MessageHeader header{2, (int)size};
                write(clientSocket, &header, sizeof(header));
                write(clientSocket, buffer, size);
            }
            delete[] buffer;
            audioFile.close();
        } else if (choice == 3) {
            break;
        } else {
            cout << "invalid input" << endl;
            continue;
        }
        
        char buffer[4096];
        while (true) {
            memset(buffer, 0, sizeof(buffer));
            ssize_t bytes_received = read(clientSocket, buffer, sizeof(buffer) - 1);
            if (bytes_received <= 0) {
                break;
            }
            ss.write(buffer, bytes_received);
            if (buffer[bytes_received - 1] == '\n' || buffer[bytes_received - 1] == '\0') {
                break;
            }
        }

        string response = ss.str();
        cout << "Server response: " << response << endl;
        cout.flush();
    }

    cout << "disconnecting......" << endl;
    close(clientSocket);
    return 0;
}
