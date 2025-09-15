//
//  BSUIRAPIBridge.h
//  BSUIRApp Objective-C++ Bridge Header
//
//  Bridge between Swift UI and C++ Core
//

#ifndef BSUIRAPIBridge_h
#define BSUIRAPIBridge_h

#import <Foundation/Foundation.h>

// Forward declarations for Swift interoperability
@class BSUIRUser;
@class BSUIRPersonalInfo;
@class BSUIRMarkbook;
@class BSUIRGroupInfo;

// Error handling
typedef NS_ENUM(NSInteger, BSUIRAPIError) {
    BSUIRAPIErrorNone = 0,
    BSUIRAPIErrorNetworkFailure = 1,
    BSUIRAPIErrorInvalidCredentials = 2,
    BSUIRAPIErrorTokenExpired = 3,
    BSUIRAPIErrorParsingError = 4,
    BSUIRAPIErrorUnknown = 5
};

// Completion block types
typedef void (^BSUIRLoginCompletion)(BSUIRUser* _Nullable user, NSError* _Nullable error);
typedef void (^BSUIRPersonalInfoCompletion)(BSUIRPersonalInfo* _Nullable info, NSError* _Nullable error);
typedef void (^BSUIRMarkbookCompletion)(BSUIRMarkbook* _Nullable markbook, NSError* _Nullable error);
typedef void (^BSUIRGroupInfoCompletion)(BSUIRGroupInfo* _Nullable groupInfo, NSError* _Nullable error);

NS_ASSUME_NONNULL_BEGIN

// Main API Bridge Interface
@interface BSUIRAPIBridge : NSObject

// Singleton instance
+ (instancetype)shared;

// Authentication
- (void)loginWithStudentNumber:(NSString*)studentNumber 
                      password:(NSString*)password 
                    completion:(BSUIRLoginCompletion)completion;

- (void)logout;
- (BOOL)isAuthenticated;

// Data fetching
- (void)getPersonalInfoWithCompletion:(BSUIRPersonalInfoCompletion)completion;
- (void)getMarkbookWithCompletion:(BSUIRMarkbookCompletion)completion;
- (void)getGroupInfoWithCompletion:(BSUIRGroupInfoCompletion)completion;

// Token management
- (void)setAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken;
- (nullable NSString*)getAccessToken;
- (nullable NSString*)getRefreshToken;

@end

NS_ASSUME_NONNULL_END

#endif /* BSUIRAPIBridge_h */