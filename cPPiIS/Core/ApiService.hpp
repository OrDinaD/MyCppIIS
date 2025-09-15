//
//  ApiService.hpp
//  cPPiIS Core C++ API Service
//
//  Main API service class for BSUIR IIS integration - C++ OOP coursework
//  Demonstrates modern C++ OOP principles and design patterns
//

#ifndef ApiService_hpp
#define ApiService_hpp

#include "Models.hpp"
#include "HTTPClient.hpp"
#include "JSONParser.hpp"
#include "IConfigProvider.hpp"
#include "BSUIROOPDemo.hpp"
#include <functional>
#include <memory>

namespace BSUIR {

/**
 * @brief Callback types for API operations with strong typing
 */
using LoginCallback = std::function<void(const ApiResult<LoginResponse>&)>;
using PersonalInfoCallback = std::function<void(const ApiResult<PersonalInfo>&)>;
using MarkbookCallback = std::function<void(const ApiResult<Markbook>&)>;
using GroupInfoCallback = std::function<void(const ApiResult<GroupInfo>&)>;

/**
 * @brief Main API service implementing OOP principles and design patterns
 * 
 * This class demonstrates:
 * - Inheritance from AbstractApiService (Template Method pattern)
 * - Dependency Injection for configuration
 * - RAII and smart pointer usage
 * - Observer pattern for notifications
 * - Polymorphism and virtual methods
 * - Const correctness and modern C++ features
 */
class ApiService : public AbstractApiService, public Subject {
private:
    std::unique_ptr<HTTPClient> httpClient;
    std::unique_ptr<IConfigProvider> configProvider;
    std::string currentAccessToken;
    std::string currentRefreshToken;
    
    /**
     * @brief Set authentication token for requests
     * @param token Access token
     */
    void setAuthToken(const std::string& token);
    
    /**
     * @brief Handle login response and parse user data
     * @param response HTTP response from server
     * @param callback Login completion callback
     */
    void handleLoginResponse(const HTTPResponse& response, LoginCallback callback);
    
    /**
     * @brief Handle personal info response
     * @param response HTTP response from server
     * @param callback Personal info completion callback
     */
    void handlePersonalInfoResponse(const HTTPResponse& response, PersonalInfoCallback callback);
    
    /**
     * @brief Handle markbook response
     * @param response HTTP response from server
     * @param callback Markbook completion callback
     */
    void handleMarkbookResponse(const HTTPResponse& response, MarkbookCallback callback);
    
    /**
     * @brief Handle group info response
     * @param response HTTP response from server
     * @param callback Group info completion callback
     */
    void handleGroupInfoResponse(const HTTPResponse& response, GroupInfoCallback callback);
    
    /**
     * @brief Create error result with consistent error handling
     * @tparam T Result data type
     * @param message Error message
     * @param code Error code
     * @return ApiResult with error
     */
    template<typename T>
    ApiResult<T> createErrorResult(const std::string& message, int code = 0);

protected:
    // AbstractApiService interface implementation (Template Method pattern)
    
    /**
     * @brief Validate request parameters before sending
     * @return true if validation passes
     */
    bool validateRequest() const override;
    
    /**
     * @brief Build API endpoint URL
     * @return Complete endpoint URL
     */
    std::string buildEndpoint() const override;
    
    /**
     * @brief Log request for debugging and monitoring
     */
    void logRequest() const override;
    
    /**
     * @brief Execute the actual HTTP request
     * @param endpoint Complete endpoint URL
     * @return true if request was sent successfully
     */
    bool executeRequest(const std::string& endpoint) override;
    
public:
    /**
     * @brief Constructor with dependency injection
     * @param config Configuration provider (injected dependency)
     * @param httpClientPtr Optional HTTP client (default: creates new instance)
     */
    explicit ApiService(
        std::unique_ptr<IConfigProvider> config,
        std::unique_ptr<HTTPClient> httpClientPtr = nullptr
    );
    
    /**
     * @brief Destructor ensuring proper cleanup
     */
    ~ApiService();
    
    // Delete copy constructor and assignment operator
    ApiService(const ApiService&) = delete;
    ApiService& operator=(const ApiService&) = delete;
    
    // Allow move constructor and assignment
    ApiService(ApiService&&) = default;
    ApiService& operator=(ApiService&&) = default;
    
    /**
     * @brief Authenticate user with credentials
     * @param studentNumber Student identification number
     * @param password User password
     * @param callback Completion callback with result
     */
    void login(const std::string& studentNumber, 
               const std::string& password, 
               LoginCallback callback);
    
    /**
     * @brief Logout current user and clear tokens
     */
    void logout();
    
    /**
     * @brief Check if user is currently authenticated
     * @return true if access token is valid
     */
    bool isAuthenticated() const noexcept;
    
    /**
     * @brief Get user personal information
     * @param callback Completion callback with result
     */
    void getPersonalInfo(PersonalInfoCallback callback);
    
    /**
     * @brief Get user markbook data
     * @param callback Completion callback with result
     */
    void getMarkbook(MarkbookCallback callback);
    
    /**
     * @brief Get user group information
     * @param callback Completion callback with result
     */
    void getGroupInfo(GroupInfoCallback callback);
    
    /**
     * @brief Set authentication tokens manually
     * @param accessToken Access token
     * @param refreshToken Refresh token
     */
    void setTokens(const std::string& accessToken, const std::string& refreshToken);
    
    /**
     * @brief Get current access token
     * @return Access token string (empty if not authenticated)
     */
    std::string getAccessToken() const;
    
    /**
     * @brief Get current refresh token
     * @return Refresh token string (empty if not authenticated)
     */
    std::string getRefreshToken() const;
    
    /**
     * @brief Get configuration provider (for testing or debugging)
     * @return Reference to configuration provider
     */
    const IConfigProvider& getConfig() const;
};

/**
 * @brief Factory class for creating API service instances
 * 
 * Demonstrates Factory Pattern and Dependency Injection
 */
class ApiServiceFactory {
public:
    /**
     * @brief Create production API service
     * @return Unique pointer to configured API service
     */
    static std::unique_ptr<ApiService> createProductionService();
    
    /**
     * @brief Create development API service
     * @return Unique pointer to configured API service
     */
    static std::unique_ptr<ApiService> createDevelopmentService();
    
    /**
     * @brief Create test API service
     * @return Unique pointer to configured API service
     */
    static std::unique_ptr<ApiService> createTestService();
    
    /**
     * @brief Create API service with custom configuration
     * @param config Custom configuration provider
     * @return Unique pointer to configured API service
     */
    static std::unique_ptr<ApiService> createCustomService(
        std::unique_ptr<IConfigProvider> config
    );
};

} // namespace BSUIR

#endif /* ApiService_hpp */