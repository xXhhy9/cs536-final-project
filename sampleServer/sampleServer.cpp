/**
 * @file
 * @author
 * - Haoyu Zhang
 */

#include "header.hpp"

using namespace std;

inline string buildPostRequest(const string& new_query);

thread_local vector<pair<string, string>> history;

void handle_client(socket_t *clientSocket) {
    
    while (true) {
        vector<char> buffer(4096);
        
        int read_bytes;
        if (socket_read(clientSocket, buffer) < 0) {
            cerr << "Read Socket Error" << endl;
            break;
        }

        if (socket_read(clientSocket, buffer) == 0) {
            break;
        }

        // handle incoming question.
        auto null_pos = std::find(buffer.begin(), buffer.end(), '\0');
        string new_question(buffer.begin(), null_pos);
        cout << new_question.length() << endl;
        string query = buildPostRequest(new_question);
        cout << query << endl;
        fflush(stdout);
        string response = callChatGPT(query);

        cout << response << endl;
        cout.flush();
        //TODO: handle empty request
        if (socket_write(clientSocket, response) < 0) {
            cerr << "Write Socket Error" << endl;
            break;
        }
        history.push_back(make_pair(new_question, response));
    }

    close_socket(clientSocket);
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

void accept_clients(acceptor* s_acceptor) {    
    while (1) {
        socket_t *sock = accept_connection(s_acceptor);

        try {
            thread client_thread(handle_client, sock);
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

    int PORT = atoi(argv[1]);
    
    acceptor* s_acceptor = create_socket_acceptor(PORT);
    if (!s_acceptor) {
        std::cerr << "Failed to create acceptor on port " << PORT << std::endl;
        return 1;
    }

    // Initialize libcurl
    curl_global_init(CURL_GLOBAL_DEFAULT);
    printf("Server is listening on %s:%d\n", inet_ntoa(s_acceptor->addr.sin_addr), PORT);

    thread acceptClient(accept_clients, s_acceptor);
    acceptClient.join();

    // Global cleanup for libcurl
    curl_global_cleanup();
    close_socket_acceptor(s_acceptor);
    return 0;
}
