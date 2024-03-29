/**
 * @file
 * @author
 * - Haoyu Zhang
 */

#include "header.hpp"

static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp);

// Function to call the ChatGPT API
int callChatGPT(const string& new_query, string& message, socket_t *clientSocket) {
    CURL* curl;
    CURLcode res;
    string readBuffer;
    curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.openai.com/v1/chat/completions");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        // Set API key and other HTTP headers
        struct curl_slist *headers = NULL;
        headers = curl_slist_append(headers, apiKey.c_str());
        headers = curl_slist_append(headers, text_request.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, new_query.c_str());

        res = curl_easy_perform(curl);
        if(res != CURLE_OK) {
            cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << endl;
            return -1;
        }

        auto jsonResponse = nlohmann::json::parse(readBuffer);
        auto choices = jsonResponse["choices"];

        if (!choices[0]["message"]["content"].empty()) {
            message = "";
            message = choices[0]["message"]["content"];
            auto request_tok = jsonResponse["usage"]["prompt_tokens"];
            auto res_tok = jsonResponse["usage"]["completion_tokens"];
            uint16_t request_tok_uint16 = static_cast<uint16_t>(request_tok.get<int>());
            uint16_t res_tok_uint16 = static_cast<uint16_t>(res_tok.get<int>());

            char *ip = inet_ntoa(clientSocket->addr.sin_addr);
            uint16_t port = ntohs(clientSocket->addr.sin_port);
            printf("Client: %s:%d    |   Request Tokens: %d    |   ChatGPT Response Tokens: %d\n", ip, port, request_tok_uint16, res_tok_uint16);
        } else {
            return -1;
        }

        // Cleanup
        curl_easy_cleanup(curl);
        return message.length();
    }

    return -1;
}

string speechtoText (const string& path) {
    CURL* curl;
    CURLcode res;
    string readBuffer;

    curl = curl_easy_init();
    if(curl) {
        struct curl_httppost* formpost = NULL;
        struct curl_httppost* lastptr = NULL;
        struct curl_slist* headerlist = NULL;

        // Add the Authorization header
        headerlist = curl_slist_append(headerlist, apiKey.c_str());

        // Add the file field
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "file",
                     CURLFORM_FILE, path.c_str(),
                     CURLFORM_END);

        // Add the model field
        curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "model",
                     CURLFORM_COPYCONTENTS, "whisper-1",
                     CURLFORM_END);

        // Set up the request
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.openai.com/v1/audio/transcriptions");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
        curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        // Perform the request
        res = curl_easy_perform(curl);

        // Check for errors
        if(res != CURLE_OK)
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));

        // Clean up
        auto jsonResponse = nlohmann::json::parse(readBuffer);
        auto choices = jsonResponse["text"];
        if (!choices.empty()) {
            readBuffer = choices;
        }
        curl_easy_cleanup(curl);
        curl_formfree(formpost);
        curl_slist_free_all(headerlist);
    }
    return readBuffer;
}

// libcurl callback function to capture the API response
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}