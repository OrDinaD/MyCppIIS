//
//  ApiService.cpp
//  BSUIRApp Core C++ API Service Implementation
//

#include "ApiService.hpp"
#include "../Config.h"

namespace BSUIR {

ApiService::ApiService(const std::string& baseURL) {
    httpClient = std::make_unique<HTTPClient>();
    httpClient->setBaseUrl(baseURL);
}

ApiService::~ApiService() = default;

void ApiService::setAuthToken(const std::string& token) {
    currentAccessToken = token;
    httpClient->setDefaultHeader("Authorization", "Bearer " + token);
}

void ApiService::login(const std::string& studentNumber, 
                      const std::string& password, 
                      LoginCallback callback) {
    
    std::string requestBody = JSONParser::createLoginRequest(studentNumber, password, true);
    
    httpClient->post(API_LOGIN_ENDPOINT, requestBody, [this, callback](const HTTPResponse& response) {
        this->handleLoginResponse(response, callback);
    });
}

void ApiService::handleLoginResponse(const HTTPResponse& response, LoginCallback callback) {
    if (response.statusCode == 200) {
        auto loginData = JSONParser::parseLoginResponse(response.data);
        if (loginData.has_value()) {
            currentAccessToken = loginData->accessToken;
            currentRefreshToken = loginData->refreshToken;
            httpClient->setDefaultHeader("Authorization", "Bearer " + currentAccessToken);
            callback(ApiResult<LoginResponse>(std::move(loginData.value())));
        } else {
            ApiError error = JSONParser::parseError(response.data, response.statusCode);
            callback(ApiResult<LoginResponse>(error));
        }
    } else {
        ApiError error = JSONParser::parseError(response.data, response.statusCode);
        callback(ApiResult<LoginResponse>(error));
    }
}

void ApiService::logout() {
    currentAccessToken.clear();
    currentRefreshToken.clear();
    httpClient->removeDefaultHeader("Authorization");
}

bool ApiService::isAuthenticated() const {
    return !currentAccessToken.empty();
}

void ApiService::getPersonalInfo(PersonalInfoCallback callback) {
    if (!isAuthenticated()) {
        ApiError error;
        error.code = 401;
        error.message = "Not authenticated";
        callback(ApiResult<PersonalInfo>(error));
        return;
    }
    
    httpClient->get(API_PERSONAL_INFO_ENDPOINT, [this, callback](const HTTPResponse& response) {
        this->handlePersonalInfoResponse(response, callback);
    });
}

void ApiService::handlePersonalInfoResponse(const HTTPResponse& response, PersonalInfoCallback callback) {
    if (response.statusCode == 200) {
        auto personalInfo = JSONParser::parsePersonalInfo(response.data);
        if (personalInfo.has_value()) {
            callback(ApiResult<PersonalInfo>(std::move(personalInfo.value())));
        } else {
            ApiError error = JSONParser::parseError(response.data, response.statusCode);
            callback(ApiResult<PersonalInfo>(error));
        }
    } else {
        ApiError error = JSONParser::parseError(response.data, response.statusCode);
        callback(ApiResult<PersonalInfo>(error));
    }
}

void ApiService::getMarkbook(MarkbookCallback callback) {
    if (!isAuthenticated()) {
        ApiError error;
        error.code = 401;
        error.message = "Not authenticated";
        callback(ApiResult<Markbook>(error));
        return;
    }
    
    httpClient->get(API_MARKBOOK_ENDPOINT, [this, callback](const HTTPResponse& response) {
        this->handleMarkbookResponse(response, callback);
    });
}

void ApiService::handleMarkbookResponse(const HTTPResponse& response, MarkbookCallback callback) {
    if (response.statusCode == 200) {
        auto markbook = JSONParser::parseMarkbook(response.data);
        if (markbook.has_value()) {
            callback(ApiResult<Markbook>(std::move(markbook.value())));
        } else {
            ApiError error = JSONParser::parseError(response.data, response.statusCode);
            callback(ApiResult<Markbook>(error));
        }
    } else {
        ApiError error = JSONParser::parseError(response.data, response.statusCode);
        callback(ApiResult<Markbook>(error));
    }
}

void ApiService::getGroupInfo(GroupInfoCallback callback) {
    if (!isAuthenticated()) {
        ApiError error;
        error.code = 401;
        error.message = "Not authenticated";
        callback(ApiResult<GroupInfo>(error));
        return;
    }
    
    httpClient->get(API_GROUP_INFO_ENDPOINT, [this, callback](const HTTPResponse& response) {
        this->handleGroupInfoResponse(response, callback);
    });
}

void ApiService::handleGroupInfoResponse(const HTTPResponse& response, GroupInfoCallback callback) {
    if (response.statusCode == 200) {
        auto groupInfo = JSONParser::parseGroupInfo(response.data);
        if (groupInfo.has_value()) {
            callback(ApiResult<GroupInfo>(std::move(groupInfo.value())));
        } else {
            ApiError error = JSONParser::parseError(response.data, response.statusCode);
            callback(ApiResult<GroupInfo>(error));
        }
    } else {
        ApiError error = JSONParser::parseError(response.data, response.statusCode);
        callback(ApiResult<GroupInfo>(error));
    }
}

void ApiService::setTokens(const std::string& accessToken, const std::string& refreshToken) {
    currentAccessToken = accessToken;
    currentRefreshToken = refreshToken;
    setAuthToken(accessToken);
}

std::string ApiService::getAccessToken() const {
    return currentAccessToken;
}

std::string ApiService::getRefreshToken() const {
    return currentRefreshToken;
}

template<typename T>
ApiResult<T> ApiService::createErrorResult(const std::string& message, int code) {
    ApiError error;
    error.code = code;
    error.message = message;
    return ApiResult<T>(error);
}

} // namespace BSUIR