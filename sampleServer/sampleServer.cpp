/**
 * @file
 * @author
 * - Haoyu Zhang
 */

#include "header.hpp"

using namespace std;

inline string buildPostRequest(const string& new_query);

thread_local vector<pair<string, string>> history;

void handle_client(ClientThreadArgs args) {
    const int clientSocket = args.sockfd;
    struct sockaddr_in address = args.server;
    char buffer[4096];
    while (true) {
        // Step 1. read message header
        MessageHeader header;
        if ((read(clientSocket, &header, sizeof(header))) <= 0) {
            break;
        }

        if (header.type == 1) {
            bzero(buffer, sizeof(buffer));
            if ((read(clientSocket, buffer, sizeof(buffer) - 1)) < 0) break;

            // handle incoming question.
            string new_question(buffer);
            string query = buildPostRequest(new_question);
            string response = callChatGPT(query);

            cout << response << endl;
            cout.flush();
            if ((write(clientSocket, (response + '\0').c_str(), (response).size() + 1)) < 0) break;
            history.push_back(make_pair(new_question, response));
        } else if (header.type == 2) {
            cout << "audio selected" << endl;
            // handle audio
            string path = "audio/gpt.m4a";
            ofstream audioFile(path, ios::binary);
            int remaining = header.length;
            while (remaining > 0) {
                ssize_t n = read(clientSocket, buffer, min((int)sizeof(buffer), remaining));
                if (n <= 0) {
                    // Handle error or disconnection
                    break;
                }
                audioFile.write(buffer, n);
                remaining -= n;
            }
            audioFile.close();

            // Step 2: Handle Speech to text
            string transcription = speechtoText(path);
            cout << transcription << endl;
            string query = buildPostRequest(transcription);
            string response = callChatGPT(query);
            cout << response << endl;
            cout.flush();
            if ((write(clientSocket, (response + '\0').c_str(), (response).size() + 1)) < 0) break;
            history.push_back(make_pair(transcription, response));

        } else {
            string response = "invalid request";
            if ((write(clientSocket, (response + '\0').c_str(), (response).size() + 1)) < 0) break;
            continue;
        }

        
    }
    printf("Client %s:%d disconnected\n", 
                inet_ntoa(address.sin_addr), ntohs(address.sin_port));
    fflush(stdout);
    close(clientSocket);
}

inline string buildPostRequest(const string& new_query) {
    // Updated POST data format
    string postData = "{\"role\": \"system\", \"content\": \"" + instruction + "\"}, ";
    for (auto & conversation: history) {
        postData += "{\"role\": \"user\", \"content\": \"" + conversation.first + "\"},";
        postData += "{\"role\": \"assistant\", \"content\": \"" + conversation.second + "\"},";
    }

    postData += "{\"role\": \"user\", \"content\": \"" + new_query + "\"}";
    string pack = "{\"model\": \"gpt-3.5-turbo\", \"messages\": [" + postData +"], \"temperature\": " + to_string(temperature) +"}";
    return pack;
}

void accept_clients(int serverSocket) {
    int server_fd = serverSocket;
    
    while (1) {
        struct sockaddr_in address;
        int addrlen = sizeof(address);
        int client_sock = accept(server_fd, (struct sockaddr*)&address, (socklen_t*)&addrlen);
        if (client_sock < 0) {
            perror("accept");
            break;
        }
        // Print client IP and port
        printf("Client connected from %s:%d\n", 
            inet_ntoa(address.sin_addr), ntohs(address.sin_port));

        // Create thread for client and specify argument
        ClientThreadArgs args;
        args.sockfd = client_sock;
        args.server = address;

        try {
            thread client_thread(handle_client, args);
            client_thread.detach();
        } catch (const system_error& e) {
            cerr << "Failed to create thread: " << e.what() << '\n';
        }
    }
}

int main(int argc, char const* argv[]) {
    if (argc < 2) {
		fprintf(stderr, "NO PORT NUMBER\n");
		exit(EXIT_FAILURE);
	}
    int serverSocket, opt = 1;

    // Creating socket file descriptor
	if ((serverSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket failed");
		exit(EXIT_FAILURE);
	}

    if (setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR, &opt,
				sizeof(opt))) {
		perror("setsockopt");
		exit(EXIT_FAILURE);
	}

    int PORT = atoi(argv[1]);
    struct sockaddr_in serverAddress;
    serverAddress.sin_family = AF_INET;
	serverAddress.sin_addr.s_addr = INADDR_ANY;
	serverAddress.sin_port = htons(PORT);

    // Forcefully attaching socket to the input PORT number
	if (::bind(serverSocket, (struct sockaddr*)&serverAddress, sizeof(serverAddress)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }


	// Appropiate TCP listen queue length
	if (listen(serverSocket, 5) < 0) {
		perror("listen");
		exit(EXIT_FAILURE);
	}

    // Initialize libcurl
    curl_global_init(CURL_GLOBAL_DEFAULT);

    printf("Server is listening on %s:%d\n", inet_ntoa(serverAddress.sin_addr), PORT);

    thread acceptClient(accept_clients, serverSocket);
    acceptClient.join();

    // Global cleanup for libcurl
    curl_global_cleanup();
    close(serverSocket);
    return 0;
}
