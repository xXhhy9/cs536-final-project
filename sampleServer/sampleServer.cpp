/**
 * @file
 * @author
 * - Haoyu Zhang
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <iostream>
#include <string>
#include <curl/curl.h>
#include <thread>
#include <vector>
#include <cstring>
#include <sys/socket.h>
#include <ctype.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <nlohmann/json.hpp>



using namespace std;

const string instruction = "Default";

typedef struct client_thread_args {
    int sockfd;
    struct sockaddr_in server;
} client_thread_args_t;

thread_local vector<pair<string, string>> history;

// libcurl callback function to capture the API response
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// Function to call the ChatGPT API
string callChatGPT(const string& new_query) {
    CURL* curl;
    CURLcode res;
    string readBuffer;

    // Initialize libcurl

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();

    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.openai.com/v1/chat/completions");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        // Set API key and other HTTP headers
        struct curl_slist *headers = NULL;
        headers = curl_slist_append(headers, "Authorization: Bearer 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");
        headers = curl_slist_append(headers, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

        // Updated POST data format
        string postData = "{\"role\": \"system\", \"content\": \"" + instruction + "\"}, ";
        for (auto & conversation: history) {
            postData += "{\"role\": \"user\", \"content\": \"" + conversation.first + "\"},";
            postData += "{\"role\": \"assistant\", \"content\": \"" + conversation.second + "\"},";
        }

        postData += "{\"role\": \"user\", \"content\": \"" + new_query + "\"}";
        string pack = "{\"model\": \"gpt-3.5-turbo\", \"messages\": [" + postData +"], \"temperature\": 0.7}";

        cout << pack.c_str() << endl;
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, pack.c_str());

        res = curl_easy_perform(curl);

        if(res != CURLE_OK) {
            cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << endl;
        }

        auto jsonResponse = nlohmann::json::parse(readBuffer);
        auto choices = jsonResponse["choices"];

        string message = "";
        if (!choices.empty()) {
            message = choices[0]["message"]["content"];
        }

        // Cleanup
        curl_easy_cleanup(curl);
        return message;
    }

    return readBuffer;
}

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
        string response = callChatGPT(new_question);
        history.push_back(make_pair(new_question, response));
        cout << response << endl;
        response += '\0';
        cout.flush();
        ssize_t bytesSend = write(clientSocket, response.c_str(), response.size());
        if (bytesSend <= 0) {
            continue;
        }
    }
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

    printf("Server is listening on %s:%d; descriptor %d\n", inet_ntoa(serverAddress.sin_addr), PORT, serverSocket);

    thread acceptClient(accept_clients, serverSocket);
    acceptClient.join();

    // Global cleanup for libcurl
    curl_global_cleanup();
    close(serverSocket);
    return 0;
}
