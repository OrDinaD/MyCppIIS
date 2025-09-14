//
//  HTTPClient.cpp
//  BSUIRApp Core C++ HTTP Client Implementation
//

#include "HTTPClient.hpp"
#include "../Bridge/HTTPClientBridge.h"
#include <cstring>
#include <sstream>

namespace BSUIR {

// Callback wrapper structure
struct CallbackWrapper {
    BSUIR::ResponseCallback userCallback;
    HTTPClient* client;
};

// C callback adapter
void httpCallbackAdapter(const char* data, int statusCode, const char* error, void* context) {
    CallbackWrapper* wrapper = static_cast<CallbackWrapper*>(context);
    
    if (wrapper && wrapper->userCallback) {
        HTTPResponse response;
        
        if (error) {
            response.success = false;
            response.errorMessage = error;
            response.statusCode = 0;
        } else {
            response.success = (statusCode >= 200 && statusCode < 300);
            response.statusCode = statusCode;
            response.data = data ? data : "";
            
            if (!response.success) {
                response.errorMessage = "HTTP Error " + std::to_string(statusCode);
            }
        }
        
        wrapper->userCallback(response);
    }
    
    // Clean up
    delete wrapper;
}

HTTPClient::HTTPClient() : baseUrl("https://iis.bsuir.by/api/v1") {
    // Constructor
}

HTTPClient::~HTTPClient() {
    // Destructor
}

void HTTPClient::setBaseUrl(const std::string& url) {
    baseUrl = url;
}

void HTTPClient::setDefaultHeader(const std::string& key, const std::string& value) {
    defaultHeaders[key] = value;
}

void HTTPClient::removeDefaultHeader(const std::string& key) {
    defaultHeaders.erase(key);
}

std::string BSUIR::HTTPClient::buildHeadersString(const std::map<std::string, std::string>& additionalHeaders) const {
    std::ostringstream headers;
    
    // Add default headers
    for (const auto& header : defaultHeaders) {
        if (!headers.str().empty()) headers << "|";
        headers << header.first << ":" << header.second;
    }
    
    // Add additional headers
    for (const auto& header : additionalHeaders) {
        if (!headers.str().empty()) headers << "|";
        headers << header.first << ":" << header.second;
    }
    
    return headers.str();
}

std::string BSUIR::HTTPClient::buildFullUrl(const std::string& endpoint) const {
    if (endpoint.find("http://") == 0 || endpoint.find("https://") == 0) {
        return endpoint; // Already a full URL
    }
    
    std::string url = baseUrl;
    if (!url.empty() && url.back() != '/') {
        url += "/";
    }
    
    std::string cleanEndpoint = endpoint;
    if (!cleanEndpoint.empty() && cleanEndpoint.front() == '/') {
        cleanEndpoint = cleanEndpoint.substr(1);
    }
    
    return url + cleanEndpoint;
}

void BSUIR::HTTPClient::get(const std::string& endpoint, ResponseCallback callback) {
    performRequest(HTTPMethodTypeGET, endpoint, "", {}, callback);
}

void BSUIR::HTTPClient::get(const std::string& endpoint, 
        const std::map<std::string, std::string>& headers,
        ResponseCallback callback) {
    performRequest(HTTPMethodTypeGET, endpoint, "", headers, callback);
}

void BSUIR::HTTPClient::post(const std::string& endpoint, 
             const std::string& body,
             ResponseCallback callback) {
    std::map<std::string, std::string> defaultContentType = {
        {"Content-Type", "application/json"}
    };
    performRequest(HTTPMethodTypePOST, endpoint, body, defaultContentType, callback);
}

void BSUIR::HTTPClient::post(const std::string& endpoint,
                     const std::string& body,
                     const std::map<std::string, std::string>& headers,
                     ResponseCallback callback) {
    performRequest(HTTPMethodTypePOST, endpoint, body, headers, callback);
}

void BSUIR::HTTPClient::put(const std::string& endpoint,
                    const std::string& body,
                    ResponseCallback callback) {
    std::map<std::string, std::string> defaultContentType = {
        {"Content-Type", "application/json"}
    };
    performRequest(HTTPMethodTypePUT, endpoint, body, defaultContentType, callback);
}

void BSUIR::HTTPClient::put(const std::string& endpoint,
                    const std::string& body,
                    const std::map<std::string, std::string>& headers,
                    ResponseCallback callback) {
    performRequest(HTTPMethodTypePUT, endpoint, body, headers, callback);
}

void BSUIR::HTTPClient::del(const std::string& endpoint, ResponseCallback callback) {
    performRequest(HTTPMethodTypeDELETE, endpoint, "", {}, callback);
}

void BSUIR::HTTPClient::del(const std::string& endpoint,
                    const std::map<std::string, std::string>& headers,
                    ResponseCallback callback) {
    performRequest(HTTPMethodTypeDELETE, endpoint, "", headers, callback);
}

void BSUIR::HTTPClient::performRequest(HTTPMethodType method,
                               const std::string& endpoint,
                               const std::string& body,
                               const std::map<std::string, std::string>& additionalHeaders,
                               ResponseCallback callback) {
    
    std::string fullUrl = buildFullUrl(endpoint);
    std::string headersString = buildHeadersString(additionalHeaders);
    
    // Create callback wrapper
    CallbackWrapper* wrapper = new CallbackWrapper{callback, this};
    
    // Make the request
    performHTTPRequest(
        fullUrl.c_str(),
        method,
        headersString.c_str(),
        body.empty() ? nullptr : body.c_str(),
        30.0, // 30 seconds timeout
        httpCallbackAdapter,
        wrapper
    );
}

} // namespace BSUIR