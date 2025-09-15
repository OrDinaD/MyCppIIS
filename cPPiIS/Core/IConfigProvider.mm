//
//  IConfigProvider.mm
//  cPPiIS Core C++ Configuration Implementation
//
//  Configuration provider implementation - C++ OOP coursework
//

#include "IConfigProvider.hpp"

namespace BSUIR {

// ========================================
// AppConfigProvider Implementation
// ========================================

AppConfigProvider::AppConfigProvider(
    const std::string& baseUrl,
    const std::string& version,
    bool debug,
    int timeout,
    int retries
) : apiBaseUrl(baseUrl),
    appVersion(version),
    debugMode(debug),
    requestTimeout(timeout),
    maxRetryAttempts(retries) {
}

std::string AppConfigProvider::getApiBaseUrl() const {
    return apiBaseUrl;
}

std::string AppConfigProvider::getAppVersion() const {
    return appVersion;
}

bool AppConfigProvider::isDebugMode() const {
    return debugMode;
}

void AppConfigProvider::setApiBaseUrl(const std::string& url) {
    apiBaseUrl = url;
}

void AppConfigProvider::setDebugMode(bool debug) {
    debugMode = debug;
}

int AppConfigProvider::getRequestTimeout() const {
    return requestTimeout;
}

int AppConfigProvider::getMaxRetryAttempts() const {
    return maxRetryAttempts;
}

// ========================================
// ConfigProviderFactory Implementation
// ========================================

std::unique_ptr<IConfigProvider> ConfigProviderFactory::createProductionConfig() {
    return std::make_unique<AppConfigProvider>(
        "https://iis.bsuir.by/api/v1",  // Production API URL
        "1.0.0",                        // App version
        false,                          // Debug mode off
        30,                             // 30 second timeout
        3                               // 3 retry attempts
    );
}

std::unique_ptr<IConfigProvider> ConfigProviderFactory::createDevelopmentConfig() {
    return std::make_unique<AppConfigProvider>(
        "https://iis.bsuir.by/api/v1",  // Same API for dev
        "1.0.0-dev",                    // Development version
        true,                           // Debug mode on
        60,                             // Longer timeout for debugging
        1                               // Fewer retries for faster debugging
    );
}

std::unique_ptr<IConfigProvider> ConfigProviderFactory::createTestConfig() {
    return std::make_unique<AppConfigProvider>(
        "http://localhost:3000/api/v1", // Local test server
        "1.0.0-test",                   // Test version
        true,                           // Debug mode on
        10,                             // Short timeout for tests
        0                               // No retries for predictable tests
    );
}

std::unique_ptr<IConfigProvider> ConfigProviderFactory::createCustomConfig(
    const std::string& baseUrl,
    bool debug
) {
    return std::make_unique<AppConfigProvider>(
        baseUrl,
        "1.0.0-custom",
        debug,
        30,
        3
    );
}

} // namespace BSUIR