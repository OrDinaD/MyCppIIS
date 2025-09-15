//
//  SecureTokenStorage.hpp
//  cPPiIS Core C++ Secure Token Storage
//
//  Secure token management for authentication - C++ OOP coursework
//  Demonstrates secure coding practices and RAII principles
//

#ifndef SecureTokenStorage_hpp
#define SecureTokenStorage_hpp

#include <string>
#include <memory>
#include <optional>

namespace BSUIR {

/**
 * @brief Secure token storage with automatic cleanup
 * 
 * This class demonstrates:
 * - RAII (Resource Acquisition Is Initialization)
 * - Secure memory handling
 * - Modern C++ features (optional, unique_ptr)
 * - Encapsulation of sensitive data
 */
class SecureTokenStorage {
private:
    /**
     * @brief Internal secure string implementation
     */
    class SecureString {
    private:
        std::unique_ptr<char[]> data;
        size_t length;
        
    public:
        explicit SecureString(const std::string& value);
        ~SecureString();
        
        // Delete copy constructor and assignment operator
        SecureString(const SecureString&) = delete;
        SecureString& operator=(const SecureString&) = delete;
        
        // Allow move constructor and assignment
        SecureString(SecureString&&) noexcept;
        SecureString& operator=(SecureString&&) noexcept;
        
        std::string getValue() const;
        bool isEmpty() const noexcept;
        void clear();
    };
    
    std::unique_ptr<SecureString> accessToken;
    std::unique_ptr<SecureString> refreshToken;
    int64_t expirationTime;
    bool isValid;
    
public:
    /**
     * @brief Constructor initializing empty token storage
     */
    SecureTokenStorage();
    
    /**
     * @brief Destructor ensuring secure cleanup
     */
    ~SecureTokenStorage();
    
    // Delete copy constructor and assignment operator for security
    SecureTokenStorage(const SecureTokenStorage&) = delete;
    SecureTokenStorage& operator=(const SecureTokenStorage&) = delete;
    
    // Allow move constructor and assignment
    SecureTokenStorage(SecureTokenStorage&&) noexcept;
    SecureTokenStorage& operator=(SecureTokenStorage&&) noexcept;
    
    /**
     * @brief Store authentication tokens securely
     * @param accessTokenValue Access token string
     * @param refreshTokenValue Refresh token string
     * @param expiresInSeconds Expiration time in seconds from now
     */
    void storeTokens(const std::string& accessTokenValue,
                    const std::string& refreshTokenValue,
                    int expiresInSeconds = 3600);
    
    /**
     * @brief Get access token if valid and not expired
     * @return Access token or empty optional if invalid/expired
     */
    std::optional<std::string> getAccessToken() const;
    
    /**
     * @brief Get refresh token if valid
     * @return Refresh token or empty optional if invalid
     */
    std::optional<std::string> getRefreshToken() const;
    
    /**
     * @brief Check if tokens are valid and not expired
     * @return true if tokens are valid
     */
    bool hasValidTokens() const noexcept;
    
    /**
     * @brief Check if access token is expired
     * @return true if access token is expired
     */
    bool isTokenExpired() const noexcept;
    
    /**
     * @brief Clear all stored tokens securely
     */
    void clearTokens();
    
    /**
     * @brief Get time until token expiration in seconds
     * @return Seconds until expiration, 0 if expired
     */
    int64_t getTimeUntilExpiration() const noexcept;
};

/**
 * @brief Factory for creating secure token storage instances
 */
class SecureTokenStorageFactory {
public:
    /**
     * @brief Create new secure token storage instance
     * @return Unique pointer to secure token storage
     */
    static std::unique_ptr<SecureTokenStorage> create();
    
    /**
     * @brief Create secure token storage with initial tokens
     * @param accessToken Initial access token
     * @param refreshToken Initial refresh token
     * @param expiresIn Expiration time in seconds
     * @return Unique pointer to secure token storage
     */
    static std::unique_ptr<SecureTokenStorage> createWithTokens(
        const std::string& accessToken,
        const std::string& refreshToken,
        int expiresIn = 3600
    );
};

} // namespace BSUIR

#endif /* SecureTokenStorage_hpp */