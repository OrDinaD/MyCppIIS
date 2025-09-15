//
//  SecureTokenStorage.mm
//  cPPiIS Core C++ Secure Token Storage Implementation
//
//  Secure token storage implementation demonstrating modern C++ practices
//

#include "SecureTokenStorage.hpp"
#include <cstring>
#include <chrono>
#include <algorithm>

namespace BSUIR {

// ========================================
// SecureString Implementation
// ========================================

SecureTokenStorage::SecureString::SecureString(const std::string& value) 
    : length(value.length()) {
    if (length > 0) {
        data = std::make_unique<char[]>(length + 1);
        std::memcpy(data.get(), value.c_str(), length);
        data[length] = '\0';
    }
}

SecureTokenStorage::SecureString::~SecureString() {
    clear();
}

SecureTokenStorage::SecureString::SecureString(SecureString&& other) noexcept 
    : data(std::move(other.data)), length(other.length) {
    other.length = 0;
}

SecureTokenStorage::SecureString& SecureTokenStorage::SecureString::operator=(SecureString&& other) noexcept {
    if (this != &other) {
        clear();
        data = std::move(other.data);
        length = other.length;
        other.length = 0;
    }
    return *this;
}

std::string SecureTokenStorage::SecureString::getValue() const {
    if (!data || length == 0) {
        return "";
    }
    return std::string(data.get(), length);
}

bool SecureTokenStorage::SecureString::isEmpty() const noexcept {
    return !data || length == 0;
}

void SecureTokenStorage::SecureString::clear() {
    if (data && length > 0) {
        // Securely zero the memory before deallocation
        std::memset(data.get(), 0, length);
    }
    data.reset();
    length = 0;
}

// ========================================
// SecureTokenStorage Implementation
// ========================================

SecureTokenStorage::SecureTokenStorage() 
    : expirationTime(0), isValid(false) {
}

SecureTokenStorage::~SecureTokenStorage() {
    clearTokens();
}

SecureTokenStorage::SecureTokenStorage(SecureTokenStorage&& other) noexcept 
    : accessToken(std::move(other.accessToken)),
      refreshToken(std::move(other.refreshToken)),
      expirationTime(other.expirationTime),
      isValid(other.isValid) {
    other.expirationTime = 0;
    other.isValid = false;
}

SecureTokenStorage& SecureTokenStorage::operator=(SecureTokenStorage&& other) noexcept {
    if (this != &other) {
        clearTokens();
        accessToken = std::move(other.accessToken);
        refreshToken = std::move(other.refreshToken);
        expirationTime = other.expirationTime;
        isValid = other.isValid;
        other.expirationTime = 0;
        other.isValid = false;
    }
    return *this;
}

void SecureTokenStorage::storeTokens(const std::string& accessTokenValue,
                                   const std::string& refreshTokenValue,
                                   int expiresInSeconds) {
    // Clear existing tokens first
    clearTokens();
    
    // Validate input
    if (accessTokenValue.empty() && refreshTokenValue.empty()) {
        return;
    }
    
    // Store tokens securely
    if (!accessTokenValue.empty()) {
        accessToken = std::make_unique<SecureString>(accessTokenValue);
    }
    
    if (!refreshTokenValue.empty()) {
        refreshToken = std::make_unique<SecureString>(refreshTokenValue);
    }
    
    // Calculate expiration time
    auto now = std::chrono::system_clock::now();
    auto expiration = now + std::chrono::seconds(expiresInSeconds);
    expirationTime = std::chrono::duration_cast<std::chrono::seconds>(
        expiration.time_since_epoch()).count();
    
    isValid = true;
}

std::optional<std::string> SecureTokenStorage::getAccessToken() const {
    if (!isValid || !accessToken || accessToken->isEmpty() || isTokenExpired()) {
        return std::nullopt;
    }
    return accessToken->getValue();
}

std::optional<std::string> SecureTokenStorage::getRefreshToken() const {
    if (!isValid || !refreshToken || refreshToken->isEmpty()) {
        return std::nullopt;
    }
    return refreshToken->getValue();
}

bool SecureTokenStorage::hasValidTokens() const noexcept {
    return isValid && 
           accessToken && !accessToken->isEmpty() && 
           !isTokenExpired();
}

bool SecureTokenStorage::isTokenExpired() const noexcept {
    if (!isValid || expirationTime == 0) {
        return true;
    }
    
    auto now = std::chrono::system_clock::now();
    auto currentTime = std::chrono::duration_cast<std::chrono::seconds>(
        now.time_since_epoch()).count();
    
    return currentTime >= expirationTime;
}

void SecureTokenStorage::clearTokens() {
    if (accessToken) {
        accessToken->clear();
        accessToken.reset();
    }
    
    if (refreshToken) {
        refreshToken->clear();
        refreshToken.reset();
    }
    
    expirationTime = 0;
    isValid = false;
}

int64_t SecureTokenStorage::getTimeUntilExpiration() const noexcept {
    if (!isValid || expirationTime == 0) {
        return 0;
    }
    
    auto now = std::chrono::system_clock::now();
    auto currentTime = std::chrono::duration_cast<std::chrono::seconds>(
        now.time_since_epoch()).count();
    
    int64_t remaining = expirationTime - currentTime;
    return std::max(static_cast<int64_t>(0), remaining);
}

// ========================================
// SecureTokenStorageFactory Implementation
// ========================================

std::unique_ptr<SecureTokenStorage> SecureTokenStorageFactory::create() {
    return std::make_unique<SecureTokenStorage>();
}

std::unique_ptr<SecureTokenStorage> SecureTokenStorageFactory::createWithTokens(
    const std::string& accessToken,
    const std::string& refreshToken,
    int expiresIn
) {
    auto storage = std::make_unique<SecureTokenStorage>();
    storage->storeTokens(accessToken, refreshToken, expiresIn);
    return storage;
}

} // namespace BSUIR