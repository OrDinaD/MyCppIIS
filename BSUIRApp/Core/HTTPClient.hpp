//
//  HTTPClient.hpp
//  BSUIRApp Core C++ HTTP Client
//
//  HTTP client for API requests using Foundation networking
//

#ifndef HTTPClient_hpp
#define HTTPClient_hpp

#include "Models.hpp"
#include <string>
#include <map>
#include <functional>

namespace BSUIR {

// HTTP response structure
struct HTTPResponse {
    bool success = false;
    int statusCode = 0;
    std::string data;
    std::string errorMessage;
};

// Callback type for async requests
using ResponseCallback = std::function<void(const HTTPResponse&)>;

class HTTPClient {
private:
    std::string baseUrl;
    std::map<std::string, std::string> defaultHeaders;
    
    // Helper methods
    std::string buildHeadersString(const std::map<std::string, std::string>& additionalHeaders) const;
    std::string buildFullUrl(const std::string& endpoint) const;
    
public:
    HTTPClient();
    ~HTTPClient();
    
    // Configuration
    void setBaseUrl(const std::string& url);
    void setDefaultHeader(const std::string& key, const std::string& value);
    void removeDefaultHeader(const std::string& key);
    
    // HTTP methods
    void get(const std::string& endpoint, ResponseCallback callback);
    void get(const std::string& endpoint, 
            const std::map<std::string, std::string>& headers,
            ResponseCallback callback);
    
    void post(const std::string& endpoint, 
             const std::string& body,
             ResponseCallback callback);
    void post(const std::string& endpoint,
             const std::string& body,
             const std::map<std::string, std::string>& headers,
             ResponseCallback callback);
    
    void put(const std::string& endpoint,
            const std::string& body,
            ResponseCallback callback);
    void put(const std::string& endpoint,
            const std::string& body,
            const std::map<std::string, std::string>& headers,
            ResponseCallback callback);
    
    void del(const std::string& endpoint, ResponseCallback callback);
    void del(const std::string& endpoint,
            const std::map<std::string, std::string>& headers,
            ResponseCallback callback);
    
private:
    // Internal request method
    void performRequest(HTTPMethodType method,
                       const std::string& endpoint,
                       const std::string& body,
                       const std::map<std::string, std::string>& additionalHeaders,
                       ResponseCallback callback);
};

} // namespace BSUIR

#endif /* HTTPClient_hpp */