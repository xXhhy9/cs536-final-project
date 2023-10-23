/**
 * @file
 * @author
 * - Haoyu Zhang
 */

#include "header.hpp"

using namespace std;

typedef struct client_thread_args {
    int sockfd;
    struct sockaddr_in server;
} client_thread_args_t;

void handle_client(int clientSocket) {
    char buffer[1024];
    while (true) {
        bzero(buffer, sizeof(buffer));
        ssize_t n = read(clientSocket, buffer, sizeof(buffer) - 1);
        if (n <= 0) {
            break;
        }
        // handle incoming question.
        string new_question(buffer);
        if (new_question == "exit") break;
        string response = callChatGPT(new_question);
        cout << response << endl;
        response += '\0';
        cout.flush();
        ssize_t bytesSend = write(clientSocket, response.c_str(), response.size());
        if (bytesSend <= 0) {
            continue;
        }
    }
    cout << "disconnecting..." << endl;
    cout.flush();
    close(clientSocket);
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
        client_thread_args_t *args = (client_thread_args_t *)malloc(sizeof(client_thread_args_t));
        args->sockfd = client_sock;
        args->server = address;

        try {
            thread client_thread(handle_client, client_sock);
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

    printf("Server is listening on %s:%d; descriptor %d\n", inet_ntoa(serverAddress.sin_addr), PORT, serverSocket);

    thread acceptClient(accept_clients, serverSocket);
    acceptClient.join();

    // Global cleanup for libcurl
    curl_global_cleanup();
    close(serverSocket);
    return 0;
}
