//
//  HTTPClient.mm
//  cPPiIS Core C++ HTTP Client Implementation
//
//  Objective-C++ implementation using Foundation networking - C++ OOP coursework
//
//  GitHub Copilot: Используй современный C++ стиль, RAII принципы, умные указатели
//  Для Objective-C++ интеграции обеспечивай безопасность памяти
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
    
    // Enhanced debug logging
    NSLog(@"🌐 HTTPClient Response Details:");
    NSLog(@"� Status Code: %d", statusCode);
    NSLog(@"❌ Error: %s", error ? error : "None");
    NSLog(@"� Response Data Length: %lu bytes", data ? strlen(data) : 0);
    
    // Log first 500 characters of response for debugging
    if (data && strlen(data) > 0) {
        NSString *responseString = [NSString stringWithUTF8String:data];
        NSString *truncatedResponse = responseString.length > 500 ? 
            [responseString substringToIndex:500] : responseString;
        NSLog(@"📄 Response Data (truncated): %@", truncatedResponse);
    }
    
    if (wrapper && wrapper->userCallback) {
        HTTPResponse response;
        
        if (error && strlen(error) > 0) {
            response.success = false;
            response.errorMessage = error;
            response.statusCode = statusCode;
            NSLog(@"💥 Request failed with error: %s", error);
        } else {
            response.success = (statusCode >= 200 && statusCode < 300);
            response.statusCode = statusCode;
            response.data = data ? data : "";
            
            if (!response.success) {
                response.errorMessage = "HTTP Error " + std::to_string(statusCode);
                NSLog(@"🔴 HTTP Error %d: Request unsuccessful", statusCode);
            } else {
                NSLog(@"✅ Request successful with status %d", statusCode);
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

void BSUIR::HTTPClient::get(const std::string& endpoint, 
                             ResponseCallback callback,
                             const std::map<std::string, std::string>& headers) {
    performRequest(HTTPMethodTypeGET, endpoint, "", headers, callback);
}

void BSUIR::HTTPClient::post(const std::string& endpoint,
                              const std::string& body,
                              ResponseCallback callback,
                              const std::map<std::string, std::string>& headers) {
    auto mergedHeaders = headers.empty() ? 
        std::map<std::string, std::string>{{"Content-Type", "application/json"}} : headers;
    performRequest(HTTPMethodTypePOST, endpoint, body, mergedHeaders, callback);
}

void BSUIR::HTTPClient::put(const std::string& endpoint,
                             const std::string& body,
                             ResponseCallback callback,
                             const std::map<std::string, std::string>& headers) {
    auto mergedHeaders = headers.empty() ? 
        std::map<std::string, std::string>{{"Content-Type", "application/json"}} : headers;
    performRequest(HTTPMethodTypePUT, endpoint, body, mergedHeaders, callback);
}

void BSUIR::HTTPClient::deleteRequest(const std::string& endpoint,
                                      ResponseCallback callback,
                                      const std::map<std::string, std::string>& headers) {
    performRequest(HTTPMethodTypeDELETE, endpoint, "", headers, callback);
}

void BSUIR::HTTPClient::performRequest(HTTPMethodType method,
                               const std::string& endpoint,
                               const std::string& body,
                               const std::map<std::string, std::string>& additionalHeaders,
                               ResponseCallback callback) {
    
    std::string fullUrl = buildFullUrl(endpoint);
    std::string headersString = buildHeadersString(additionalHeaders);
    
    // Add debug logging
    NSLog(@"🌐 HTTPClient Request:");
    NSLog(@"🌐 Method: %ld", (long)method);
    NSLog(@"🌐 URL: %s", fullUrl.c_str());
    NSLog(@"🌐 Headers: %s", headersString.c_str());
    NSLog(@"🌐 Body: %s", body.c_str());
    
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