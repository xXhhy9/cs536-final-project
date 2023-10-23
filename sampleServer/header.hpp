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

// server global constant
const string apiKey = "Authorization: Bearer {Replace Key}"; 
const string instruction = "Default";
const string text_request = "Content-Type: application/json";
const float temperature =  0.5;
const unsigned short max_toks = 500;

// api function calls
string callChatGPT(const string& new_query);