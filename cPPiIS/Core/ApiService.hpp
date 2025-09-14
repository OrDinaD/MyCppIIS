//
//  ApiService.hpp
//  cPPiIS Core C++ API Service
//
//  Main API service class for BSUIR IIS integration - C++ OOP coursework
// ApiService.hpp
//  BSUIRApp Core C++ API Service
//
//  Main service class for BSUIR IIS API interactions
//

#ifndef ApiService_hpp
#define ApiService_hpp

#include "Models.hpp"
#include "HTTPClient.hpp"
#include "JSONParser.hpp"
#include <functional>
#include <memory>

namespace BSUIR {

// Callback types for API operations
using LoginCallback = std::function<void(const ApiResult<LoginResponse>&)>;
using PersonalInfoCallback = std::function<void(const ApiResult<PersonalInfo>&)>;
using MarkbookCallback = std::function<void(const ApiResult<Markbook>&)>;
using GroupInfoCallback = std::function<void(const ApiResult<GroupInfo>&)>;

class ApiService {
private:
    std::unique_ptr<HTTPClient> httpClient;
    std::string currentAccessToken;
    std::string currentRefreshToken;
    
    // Helper methods
    void setAuthToken(const std::string& token);
    void handleLoginResponse(const HTTPResponse& response, LoginCallback callback);
    void handlePersonalInfoResponse(const HTTPResponse& response, PersonalInfoCallback callback);
    void handleMarkbookResponse(const HTTPResponse& response, MarkbookCallback callback);
    void handleGroupInfoResponse(const HTTPResponse& response, GroupInfoCallback callback);
    
    template<typename T>
    ApiResult<T> createErrorResult(const std::string& message, int code = 0);
    
public:
    ApiService(const std::string& baseURL);
    ~ApiService();
    
    // Authentication
    void login(const std::string& studentNumber, 
               const std::string& password, 
               LoginCallback callback);
    
    void logout();
    
    // Check if user is authenticated
    bool isAuthenticated() const;
    
    // API Data methods
    void getPersonalInfo(PersonalInfoCallback callback);
    void getMarkbook(MarkbookCallback callback);
    void getGroupInfo(GroupInfoCallback callback);
    
    // Token management
    void setTokens(const std::string& accessToken, const std::string& refreshToken);
    std::string getAccessToken() const;
    std::string getRefreshToken() const;
};

} // namespace BSUIR

#endif /* ApiService_hpp */