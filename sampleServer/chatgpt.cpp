/**
 * @file
 * @author
 * - Haoyu Zhang
 */

#include "header.hpp"

static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp);
inline string buildPostRequest(const string& new_query);

thread_local vector<pair<string, string>> history;

// Function to call the ChatGPT API
string callChatGPT(const string& new_query) {
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
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, buildPostRequest(new_query).c_str());

        res = curl_easy_perform(curl);

        if(res != CURLE_OK) {
            cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << endl;
        }

        auto jsonResponse = nlohmann::json::parse(readBuffer);
        auto choices = jsonResponse["choices"];

        string message = "";
        if (!choices.empty()) {
            message = choices[0]["message"]["content"];
            history.push_back(make_pair(new_query, message));
        }

        // Cleanup
        curl_easy_cleanup(curl);
        return message;
    }

    return readBuffer;
}

// libcurl callback function to capture the API response
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
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