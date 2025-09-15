//
//  HTTPClient.hpp
//  cPPiIS Core C++ HTTP Client
//
//  HTTP client for API requests using Foundation networking - C++ OOP coursework
//  Demonstrates modern C++ practices and OOP principles
//

#ifndef HTTPClient_hpp
#define HTTPClient_hpp

#include "Models.hpp"
#include "../Bridge/HTTPClientBridge.h"
#include <string>
#include <map>
#include <functional>
#include <memory>

namespace BSUIR {

/**
 * @brief HTTP response structure containing response data and metadata
 */
struct HTTPResponse {
    bool success = false;
    int statusCode = 0;
    std::string data;
    std::string errorMessage;
    
    /**
     * @brief Check if the response indicates success
     * @return true if status code is in 200-299 range
     */
    bool isSuccessful() const noexcept {
        return success && statusCode >= 200 && statusCode < 300;
    }
};

/**
 * @brief Callback type for async HTTP requests
 */
using ResponseCallback = std::function<void(const HTTPResponse&)>;

/**
 * @brief Modern C++ HTTP Client implementing RAII and smart memory management
 * 
 * This class demonstrates:
 * - RAII (Resource Acquisition Is Initialization)
 * - Smart pointers for automatic memory management
 * - Method overloading with default parameters (instead of multiple overloads)
 * - Const correctness
 * - Modern C++ features
 */
class HTTPClient {
private:
    std::string baseUrl;
    std::map<std::string, std::string> defaultHeaders;
    
    /**
     * @brief Helper method to build headers string from maps
     * @param additionalHeaders Additional headers to merge with defaults
     * @return Combined headers as string
     */
    std::string buildHeadersString(const std::map<std::string, std::string>& additionalHeaders = {}) const;
    
    /**
     * @brief Helper method to build full URL from base URL and endpoint
     * @param endpoint API endpoint path
     * @return Complete URL string
     */
    std::string buildFullUrl(const std::string& endpoint) const;
    
public:
    /**
     * @brief Constructor initializing HTTPClient with default configuration
     */
    HTTPClient();
    
    /**
     * @brief Destructor ensuring proper cleanup (RAII principle)
     */
    ~HTTPClient();
    
    // Delete copy constructor and assignment operator to prevent accidental copying
    HTTPClient(const HTTPClient&) = delete;
    HTTPClient& operator=(const HTTPClient&) = delete;
    
    // Allow move constructor and assignment for performance
    HTTPClient(HTTPClient&&) = default;
    HTTPClient& operator=(HTTPClient&&) = default;
    
    /**
     * @brief Configure base URL for all requests
     * @param url Base URL for API endpoints
     */
    void setBaseUrl(const std::string& url);
    
    /**
     * @brief Set default header that will be included in all requests
     * @param key Header name
     * @param value Header value
     */
    void setDefaultHeader(const std::string& key, const std::string& value);
    
    /**
     * @brief Remove default header
     * @param key Header name to remove
     */
    void removeDefaultHeader(const std::string& key);
    
    /**
     * @brief Perform GET request with optional additional headers
     * @param endpoint API endpoint path
     * @param callback Response callback function
     * @param headers Optional additional headers (default: empty)
     */
    void get(const std::string& endpoint, 
             ResponseCallback callback,
             const std::map<std::string, std::string>& headers = {});
    
    /**
     * @brief Perform POST request with body and optional additional headers
     * @param endpoint API endpoint path
     * @param body Request body content
     * @param callback Response callback function
     * @param headers Optional additional headers (default: empty)
     */
    void post(const std::string& endpoint,
              const std::string& body,
              ResponseCallback callback,
              const std::map<std::string, std::string>& headers = {});
    
    /**
     * @brief Perform PUT request with body and optional additional headers
     * @param endpoint API endpoint path
     * @param body Request body content
     * @param callback Response callback function
     * @param headers Optional additional headers (default: empty)
     */
    void put(const std::string& endpoint,
             const std::string& body,
             ResponseCallback callback,
             const std::map<std::string, std::string>& headers = {});
    
    /**
     * @brief Perform DELETE request with optional additional headers
     * @param endpoint API endpoint path
     * @param callback Response callback function
     * @param headers Optional additional headers (default: empty)
     */
    void deleteRequest(const std::string& endpoint,
                      ResponseCallback callback,
                      const std::map<std::string, std::string>& headers = {});

private:
    /**
     * @brief Internal unified request method implementing Template Method pattern
     * @param method HTTP method type
     * @param endpoint API endpoint path
     * @param body Request body (empty for GET/DELETE)
     * @param additionalHeaders Additional headers to merge
     * @param callback Response callback function
     */
    void performRequest(HTTPMethodType method,
                       const std::string& endpoint,
                       const std::string& body,
                       const std::map<std::string, std::string>& additionalHeaders,
                       ResponseCallback callback);
};

} // namespace BSUIR

#endif /* HTTPClient_hpp */