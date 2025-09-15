//
//  IConfigProvider.hpp
//  cPPiIS Core C++ Configuration Interface
//
//  Configuration provider interface for Dependency Injection - C++ OOP coursework
//  Demonstrates Interface Segregation Principle and Dependency Injection pattern
//

#ifndef IConfigProvider_hpp
#define IConfigProvider_hpp

#include <string>
#include <memory>

namespace BSUIR {

/**
 * @brief Abstract configuration provider interface
 * 
 * This interface demonstrates:
 * - Interface Segregation Principle
 * - Dependency Injection pattern
 * - Abstract base class design
 * - Pure virtual methods for polymorphism
 */
class IConfigProvider {
public:
    virtual ~IConfigProvider() = default;
    
    /**
     * @brief Get API base URL
     * @return Base URL for API requests
     */
    virtual std::string getApiBaseUrl() const = 0;
    
    /**
     * @brief Get application version
     * @return Current application version string
     */
    virtual std::string getAppVersion() const = 0;
    
    /**
     * @brief Check if debug mode is enabled
     * @return true if debug mode is active
     */
    virtual bool isDebugMode() const = 0;
    
    /**
     * @brief Set API base URL
     * @param url New base URL
     */
    virtual void setApiBaseUrl(const std::string& url) = 0;
    
    /**
     * @brief Set debug mode
     * @param debug Debug mode state
     */
    virtual void setDebugMode(bool debug) = 0;
    
    /**
     * @brief Get request timeout in seconds
     * @return Timeout value
     */
    virtual int getRequestTimeout() const = 0;
    
    /**
     * @brief Get maximum retry attempts
     * @return Maximum number of retry attempts
     */
    virtual int getMaxRetryAttempts() const = 0;
};

/**
 * @brief Concrete configuration provider implementation
 * 
 * This class demonstrates:
 * - Implementation of interface
 * - RAII principle
 * - Const correctness
 * - Thread safety considerations
 */
class AppConfigProvider : public IConfigProvider {
private:
    std::string apiBaseUrl;
    std::string appVersion;
    bool debugMode;
    int requestTimeout;
    int maxRetryAttempts;
    
public:
    /**
     * @brief Constructor with default configuration values
     */
    explicit AppConfigProvider(
        const std::string& baseUrl = "https://iis.bsuir.by/api/v1",
        const std::string& version = "1.0.0",
        bool debug = true,
        int timeout = 30,
        int retries = 3
    );
    
    // IConfigProvider interface implementation
    std::string getApiBaseUrl() const override;
    std::string getAppVersion() const override;
    bool isDebugMode() const override;
    void setApiBaseUrl(const std::string& url) override;
    void setDebugMode(bool debug) override;
    int getRequestTimeout() const override;
    int getMaxRetryAttempts() const override;
};

/**
 * @brief Factory class for creating configuration providers
 * 
 * Demonstrates Factory Pattern for creating configuration instances
 */
class ConfigProviderFactory {
public:
    /**
     * @brief Create production configuration provider
     * @return Unique pointer to production configuration
     */
    static std::unique_ptr<IConfigProvider> createProductionConfig();
    
    /**
     * @brief Create development configuration provider
     * @return Unique pointer to development configuration
     */
    static std::unique_ptr<IConfigProvider> createDevelopmentConfig();
    
    /**
     * @brief Create test configuration provider
     * @return Unique pointer to test configuration
     */
    static std::unique_ptr<IConfigProvider> createTestConfig();
    
    /**
     * @brief Create custom configuration provider
     * @param baseUrl API base URL
     * @param debug Debug mode flag
     * @return Unique pointer to custom configuration
     */
    static std::unique_ptr<IConfigProvider> createCustomConfig(
        const std::string& baseUrl,
        bool debug = false
    );
};

} // namespace BSUIR

#endif /* IConfigProvider_hpp */