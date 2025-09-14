//
//  Config.h
//  BSUIRApp
//
//  Configuration file for BSUIR IIS API
//

#ifndef Config_h
#define Config_h

// API Configuration
#define API_BASE_URL "https://iis.bsuir.by/api/v1"
#define API_LOGIN_ENDPOINT "/auth/login"
#define API_PERSONAL_INFO_ENDPOINT "/personal-information"
#define API_MARKBOOK_ENDPOINT "/markbook"
#define API_GROUP_INFO_ENDPOINT "/student-groups/user-group-info"

// Test Credentials (for development only)
#define TEST_LOGIN "42850012"
#define TEST_PASSWORD "Bsuirinyouv.12_"

// Network Configuration
#define REQUEST_TIMEOUT 30.0
#define MAX_RETRIES 3

// Security
#define KEYCHAIN_SERVICE "by.bsuir.app"
#define KEYCHAIN_ACCESS_TOKEN_KEY "access_token"
#define KEYCHAIN_REFRESH_TOKEN_KEY "refresh_token"

#endif /* Config_h */