//
//  ApiService.mm
//  cPPiIS Core C++ API Service Implementation
//
//  Modern C++ OOP implementation demonstrating design patterns and best practices
//

#include "ApiService.hpp"
#include "../Config.h"
#include <iostream>

namespace BSUIR {

// ========================================
// ApiService Implementation
// ========================================

ApiService::ApiService(
    std::unique_ptr<IConfigProvider> config,
    std::unique_ptr<HTTPClient> httpClientPtr
) : AbstractApiService(config->getApiBaseUrl()),
    configProvider(std::move(config)) {
    
    if (httpClientPtr) {
        httpClient = std::move(httpClientPtr);
    } else {
        httpClient = std::make_unique<HTTPClient>();
    }
    
    httpClient->setBaseUrl(configProvider->getApiBaseUrl());
    
    if (configProvider->isDebugMode()) {
        std::cout << "🚀 ApiService: Initialized with base URL: " 
                  << configProvider->getApiBaseUrl() << std::endl;
    }
}

ApiService::~ApiService() {
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "🔥 ApiService: Destructor called, cleaning up resources" << std::endl;
    }
}

// ========================================
// AbstractApiService Template Method Implementation
// ========================================

bool ApiService::validateRequest() const {
    // Basic validation - can be extended for specific request types
    return configProvider && httpClient && !configProvider->getApiBaseUrl().empty();
}

std::string ApiService::buildEndpoint() const {
    // This will be context-specific in actual requests
    return configProvider->getApiBaseUrl();
}

void ApiService::logRequest() const {
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "📤 ApiService: Making request to " << buildEndpoint() << std::endl;
    }
}

bool ApiService::executeRequest(const std::string& endpoint) {
    // This is implemented in specific request methods
    // Template method pattern allows this base implementation
    return true;
}

// ========================================
// Authentication Methods
// ========================================

void ApiService::setAuthToken(const std::string& token) {
    currentAccessToken = token;
    
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "🍪 ApiService: Session established, token length: " 
                  << token.length() << " characters" << std::endl;
    }
}

void ApiService::login(const std::string& studentNumber, 
                      const std::string& password, 
                      LoginCallback callback) {
    
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "🔐 Starting login request for student: " << studentNumber << std::endl;
    }
    
    // Validate inputs
    if (studentNumber.empty() || password.empty()) {
        auto errorResult = createErrorResult<LoginResponse>("Invalid credentials provided", 400);
        callback(errorResult);
        return;
    }
    
    // Use Template Method pattern from AbstractApiService
    if (!makeRequest()) {
        auto errorResult = createErrorResult<LoginResponse>("Request validation failed", 500);
        callback(errorResult);
        return;
    }
    
    std::string requestBody = JSONParser::createLoginRequest(studentNumber, password, false); // No rememberMe
    
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "📤 Login request body: " << requestBody << std::endl;
    }
    
    httpClient->post(API_LOGIN_ENDPOINT, requestBody, 
        [this, callback, studentNumber](const HTTPResponse& response) {
            if (configProvider && configProvider->isDebugMode()) {
                std::cout << "🔄 Login response received for student: " << studentNumber << std::endl;
            }
            this->handleLoginResponse(response, callback);
        });
}

void ApiService::handleLoginResponse(const HTTPResponse& response, LoginCallback callback) {
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "🔍 Processing login response - Status: " << response.statusCode 
                  << ", Success: " << (response.success ? "YES" : "NO") << std::endl;
        std::cout << "📦 Raw response data: " << response.data << std::endl;
    }
    
    if (!response.success) {
        if (configProvider && configProvider->isDebugMode()) {
            std::cout << "❌ Login failed - HTTP Error: " << response.errorMessage << std::endl;
        }
        auto errorResult = createErrorResult<LoginResponse>(response.errorMessage, response.statusCode);
        callback(errorResult);
        return;
    }
    
    if (response.statusCode == 200) {
        if (configProvider && configProvider->isDebugMode()) {
            std::cout << "✅ Login HTTP 200 - Parsing response data" << std::endl;
        }
        
        auto parseResult = JSONParser::parseLoginResponse(response.data);
        if (parseResult.has_value()) {
            // For BSUIR API, we don't get an access token
            // Authentication is maintained via session cookies
            // Set a dummy token to indicate authenticated state
            setAuthToken("SESSION_AUTHENTICATED");
            
            // Notify observers about successful login
            notifyUserLoggedIn(nullptr); // In real implementation, pass actual user
            
            // Create successful ApiResult
            ApiResult<LoginResponse> result(std::move(parseResult.value()));
            callback(result);
        } else {
            // Create error ApiResult from parse failure
            ApiError error{-1, "Failed to parse login response", "JSON parsing error"};
            ApiResult<LoginResponse> result(error);
            callback(result);
        }
    } else {
        auto errorResult = createErrorResult<LoginResponse>("Unexpected status code", response.statusCode);
        callback(errorResult);
    }
}

void ApiService::logout() {
    currentAccessToken.clear();
    currentRefreshToken.clear();
    
    // Notify observers about logout
    notifyUserLoggedOut();
    
    if (configProvider && configProvider->isDebugMode()) {
        std::cout << "🚪 ApiService: User logged out" << std::endl;
    }
}

bool ApiService::isAuthenticated() const noexcept {
    return !currentAccessToken.empty();
}

// ========================================
// Data Fetching Methods
// ========================================

void ApiService::getPersonalInfo(PersonalInfoCallback callback) {
    if (!isAuthenticated()) {
        auto errorResult = createErrorResult<PersonalInfo>("User not authenticated", 401);
        callback(errorResult);
        return;
    }
    
    httpClient->get(API_PERSONAL_INFO_ENDPOINT, 
        [this, callback](const HTTPResponse& response) {
            this->handlePersonalInfoResponse(response, callback);
        });
}

void ApiService::handlePersonalInfoResponse(const HTTPResponse& response, PersonalInfoCallback callback) {
    if (response.success) {
        auto parseResult = JSONParser::parsePersonalInfo(response.data);
        if (parseResult.has_value()) {
            ApiResult<PersonalInfo> result(std::move(parseResult.value()));
            callback(result);
        } else {
            ApiError error{-1, "Failed to parse personal info", "JSON parsing error"};
            ApiResult<PersonalInfo> result(error);
            callback(result);
        }
    } else {
        auto errorResult = createErrorResult<PersonalInfo>(response.errorMessage, response.statusCode);
        callback(errorResult);
    }
}

void ApiService::getMarkbook(MarkbookCallback callback) {
    if (!isAuthenticated()) {
        auto errorResult = createErrorResult<Markbook>("User not authenticated", 401);
        callback(errorResult);
        return;
    }
    
    httpClient->get(API_MARKBOOK_ENDPOINT, 
        [this, callback](const HTTPResponse& response) {
            this->handleMarkbookResponse(response, callback);
        });
}

void ApiService::handleMarkbookResponse(const HTTPResponse& response, MarkbookCallback callback) {
    if (response.success) {
        auto parseResult = JSONParser::parseMarkbook(response.data);
        if (parseResult.has_value()) {
            ApiResult<Markbook> result(std::move(parseResult.value()));
            callback(result);
        } else {
            ApiError error{-1, "Failed to parse markbook", "JSON parsing error"};
            ApiResult<Markbook> result(error);
            callback(result);
        }
    } else {
        auto errorResult = createErrorResult<Markbook>(response.errorMessage, response.statusCode);
        callback(errorResult);
    }
}

void ApiService::getGroupInfo(GroupInfoCallback callback) {
    if (!isAuthenticated()) {
        auto errorResult = createErrorResult<GroupInfo>("User not authenticated", 401);
        callback(errorResult);
        return;
    }
    
    httpClient->get(API_GROUP_INFO_ENDPOINT, 
        [this, callback](const HTTPResponse& response) {
            this->handleGroupInfoResponse(response, callback);
        });
}

void ApiService::handleGroupInfoResponse(const HTTPResponse& response, GroupInfoCallback callback) {
    if (response.success) {
        auto parseResult = JSONParser::parseGroupInfo(response.data);
        if (parseResult.has_value()) {
            ApiResult<GroupInfo> result(std::move(parseResult.value()));
            callback(result);
        } else {
            ApiError error{-1, "Failed to parse group info", "JSON parsing error"};
            ApiResult<GroupInfo> result(error);
            callback(result);
        }
    } else {
        auto errorResult = createErrorResult<GroupInfo>(response.errorMessage, response.statusCode);
        callback(errorResult);
    }
}

// ========================================
// Token Management
// ========================================

void ApiService::setTokens(const std::string& accessToken, const std::string& refreshToken) {
    currentAccessToken = accessToken;
    currentRefreshToken = refreshToken;
}

std::string ApiService::getAccessToken() const {
    return currentAccessToken;
}

std::string ApiService::getRefreshToken() const {
    return currentRefreshToken;
}

const IConfigProvider& ApiService::getConfig() const {
    return *configProvider;
}

// ========================================
// Template Helper Method
// ========================================

template<typename T>
ApiResult<T> ApiService::createErrorResult(const std::string& message, int code) {
    ApiError error{code, message, ""};
    return ApiResult<T>(error);
}

// ========================================
// ApiServiceFactory Implementation
// ========================================

std::unique_ptr<ApiService> ApiServiceFactory::createProductionService() {
    auto config = ConfigProviderFactory::createProductionConfig();
    return std::make_unique<ApiService>(std::move(config));
}

std::unique_ptr<ApiService> ApiServiceFactory::createDevelopmentService() {
    auto config = ConfigProviderFactory::createDevelopmentConfig();
    return std::make_unique<ApiService>(std::move(config));
}

std::unique_ptr<ApiService> ApiServiceFactory::createTestService() {
    auto config = ConfigProviderFactory::createTestConfig();
    return std::make_unique<ApiService>(std::move(config));
}

std::unique_ptr<ApiService> ApiServiceFactory::createCustomService(
    std::unique_ptr<IConfigProvider> config
) {
    return std::make_unique<ApiService>(std::move(config));
}

// Notification methods implementation
void ApiService::notifyUserLoggedIn(const AbstractUser* user) {
    // Notify all observers that user has logged in using the ObserverSubject method
    ObserverSubject::notifyUserLoggedIn(user);
}

void ApiService::notifyUserLoggedOut() {
    // Notify all observers that user has logged out using the ObserverSubject method
    ObserverSubject::notifyUserLoggedOut();
}

} // namespace BSUIR
