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
#include <fstream>
#include <sstream>

using namespace std;

// server global constant
const string apiKey = "Authorization: Bearer sk-"; 
const string instruction = "Default";
const string text_request = "Content-Type: application/json";
const float temperature =  0.5;
const unsigned short max_toks = 500;

// api function calls
int callChatGPT(const string& new_query, string& message);
string speechtoText(const string& path);

// socket type
#ifdef USE_TLS
#include "tls.hpp"
typedef tls_socket socket_t;
typedef tls_acceptor acceptor;
#else
#include "tcp.hpp"
typedef tcp_socket socket_t;
typedef tcp_acceptor acceptor;
#endif

int socket_read(socket_t *socket, std::vector<char>& buf);
int socket_write(socket_t *socket, const std::string& str);
int close_socket(socket_t *socket);

acceptor *create_socket_acceptor(int port);
socket_t *accept_connection(acceptor *socket_acceptor);
int close_socket_acceptor(acceptor* socket_acceptor);
