//
//  BSUIRAPIBridge.mm
//  BSUIRApp Objective-C++ Bridge Implementation
//

#import "BSUIRAPIBridge.h"
#import "BSUIRModels.h"
#include "../Core/ApiService.hpp"
#include "../Config.h"
#include <memory>

@interface BSUIRAPIBridge () {
    std::unique_ptr<BSUIR::ApiService> _apiService;
}
@end

@implementation BSUIRAPIBridge

+ (instancetype)shared {
    static BSUIRAPIBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create configuration provider with base URL
        auto config = std::make_unique<BSUIR::AppConfigProvider>(
            API_BASE_URL,  // baseUrl
            "1.0.0",       // version
            true,          // debug mode
            30,            // timeout in seconds
            3              // max retries
        );
        
        _apiService = std::make_unique<BSUIR::ApiService>(std::move(config));
        
        NSLog(@"🚀 BSUIRAPIBridge: Initialized with base URL: %s", API_BASE_URL);
    }
    return self;
}

#pragma mark - Authentication

- (void)loginWithStudentNumber:(NSString*)studentNumber 
                      password:(NSString*)password 
                    completion:(BSUIRLoginCompletion)completion {
    
    NSLog(@"🚀 BSUIRAPIBridge: Starting login process");
    NSLog(@"👤 Student Number: %@", studentNumber ?: @"(nil)");
    NSLog(@"🔒 Password: %@", password ? @"[PROTECTED]" : @"(nil)");
    
    if (!studentNumber || !password || !completion) {
        NSLog(@"❌ BSUIRAPIBridge: Invalid parameters provided");
        
        NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                             code:BSUIRAPIErrorInvalidCredentials 
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid credentials provided"}];
        completion(nil, error);
        return;
    }
    
    std::string stdStudentNumber = [studentNumber UTF8String];
    std::string stdPassword = [password UTF8String];
    
    NSLog(@"🔧 BSUIRAPIBridge: Calling C++ ApiService for authentication");
    
    _apiService->login(stdStudentNumber, stdPassword, [completion, studentNumber](const BSUIR::ApiResult<BSUIR::LoginResponse>& result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"📥 BSUIRAPIBridge: Received response from C++ ApiService, success: %s", result.success ? "YES" : "NO");
            
            if (result.success && result.data.has_value()) {
                NSLog(@"🎉 BSUIRAPIBridge: Authentication successful for student: %@", studentNumber);
                
                const auto& loginData = result.data.value();
                
                BSUIRUser *user = [[BSUIRUser alloc] init];
                user.studentNumber = [NSString stringWithUTF8String:loginData.studentNumber.c_str()];
                user.firstName = [NSString stringWithUTF8String:loginData.firstName.c_str()];
                user.lastName = [NSString stringWithUTF8String:loginData.lastName.c_str()];
                user.middleName = [NSString stringWithUTF8String:loginData.middleName.c_str()];
                user.accessToken = [NSString stringWithUTF8String:loginData.accessToken.c_str()];
                user.refreshToken = [NSString stringWithUTF8String:loginData.refreshToken.c_str()];
                user.userId = loginData.userId;
                user.expiresIn = loginData.expiresIn;
                
                // [[BSUIRLogBridge shared] successWithCategory:@"Auth" 
                //                                      message:@"Объект пользователя создан" 
                //                                     metadata:@{
                //                                         @"userName": [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName],
                //                                         @"userId": [NSString stringWithFormat:@"%d", user.userId]
                //                                     }];
                NSLog(@"👤 BSUIRAPIBridge: User object created for %@ %@, ID: %ld", user.firstName, user.lastName, static_cast<long>(user.userId));
                
                completion(user, nil);
            } else if (result.error.has_value()) {
                const auto& apiError = result.error.value();
                
                NSLog(@"🚫 BSUIRAPIBridge: Authentication failed for %@", studentNumber);
                NSLog(@"📋 API Error - Code: %d, Message: %s, Details: %s", apiError.code, apiError.message.c_str(), apiError.details.c_str());
                
                // Safely convert C++ strings to NSString, handling potential nil values
                NSString *messageStr = [NSString stringWithUTF8String:apiError.message.c_str()];
                NSString *detailsStr = [NSString stringWithUTF8String:apiError.details.c_str()];
                
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:apiError.code 
                                                 userInfo:@{
                                                     NSLocalizedDescriptionKey: messageStr ?: @"API Error",
                                                     NSLocalizedFailureReasonErrorKey: detailsStr ?: @"No details available"
                                                 }];
                completion(nil, error);
            } else {
                NSLog(@"⚠️ BSUIRAPIBridge: Unknown error occurred during login");
                
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:BSUIRAPIErrorUnknown 
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Unknown error occurred during login"}];
                completion(nil, error);
            }
        });
    });
}

- (void)logout {
    _apiService->logout();
}

- (BOOL)isAuthenticated {
    return _apiService->isAuthenticated();
}

#pragma mark - Data Fetching

- (void)getPersonalInfoWithCompletion:(BSUIRPersonalInfoCompletion)completion {
    if (!completion) return;
    
    NSLog(@"🔍 BSUIRAPIBridge: Starting getPersonalInfo request");
    
    _apiService->getPersonalInfo([completion](const BSUIR::ApiResult<BSUIR::PersonalInfo>& result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"📥 BSUIRAPIBridge: Received PersonalInfo response, success: %s", result.success ? "YES" : "NO");
            
            if (result.success && result.data.has_value()) {
                const auto& info = result.data.value();
                
                BSUIRPersonalInfo *personalInfo = [[BSUIRPersonalInfo alloc] init];
                
                // Safe string conversion with null checks
                personalInfo.userId = info.id;
                personalInfo.studentNumber = info.studentNumber.empty() ? @"" : [NSString stringWithUTF8String:info.studentNumber.c_str()];
                personalInfo.firstName = info.firstName.empty() ? @"" : [NSString stringWithUTF8String:info.firstName.c_str()];
                personalInfo.lastName = info.lastName.empty() ? @"" : [NSString stringWithUTF8String:info.lastName.c_str()];
                personalInfo.middleName = info.middleName.empty() ? @"" : [NSString stringWithUTF8String:info.middleName.c_str()];
                personalInfo.firstNameBel = info.firstNameBel.empty() ? @"" : [NSString stringWithUTF8String:info.firstNameBel.c_str()];
                personalInfo.lastNameBel = info.lastNameBel.empty() ? @"" : [NSString stringWithUTF8String:info.lastNameBel.c_str()];
                personalInfo.middleNameBel = info.middleNameBel.empty() ? @"" : [NSString stringWithUTF8String:info.middleNameBel.c_str()];
                personalInfo.birthDate = info.birthDate.empty() ? @"" : [NSString stringWithUTF8String:info.birthDate.c_str()];
                personalInfo.course = info.course;
                personalInfo.faculty = info.faculty.empty() ? @"" : [NSString stringWithUTF8String:info.faculty.c_str()];
                personalInfo.speciality = info.speciality.empty() ? @"" : [NSString stringWithUTF8String:info.speciality.c_str()];
                personalInfo.group = info.group.empty() ? @"" : [NSString stringWithUTF8String:info.group.c_str()];
                personalInfo.email = info.email.empty() ? @"" : [NSString stringWithUTF8String:info.email.c_str()];
                personalInfo.phone = info.phone.empty() ? @"" : [NSString stringWithUTF8String:info.phone.c_str()];
                
                NSLog(@"✅ BSUIRAPIBridge: PersonalInfo object created for %@ %@", personalInfo.firstName, personalInfo.lastName);
                completion(personalInfo, nil);
            } else if (result.error.has_value()) {
                const auto& apiError = result.error.value();
                NSLog(@"❌ BSUIRAPIBridge: PersonalInfo error - Code: %d, Message: %s", apiError.code, apiError.message.c_str());
                
                NSString *messageStr = apiError.message.empty() ? @"Failed to get personal info" : [NSString stringWithUTF8String:apiError.message.c_str()];
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:apiError.code 
                                                 userInfo:@{NSLocalizedDescriptionKey: messageStr}];
                completion(nil, error);
            } else {
                NSLog(@"❌ BSUIRAPIBridge: Unknown error getting PersonalInfo");
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:BSUIRAPIErrorUnknown 
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to get personal info"}];
                completion(nil, error);
            }
        });
    });
}

- (void)getMarkbookWithCompletion:(BSUIRMarkbookCompletion)completion {
    if (!completion) return;
    
    _apiService->getMarkbook([completion](const BSUIR::ApiResult<BSUIR::Markbook>& result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success && result.data.has_value()) {
                const auto& markbook = result.data.value();
                
                BSUIRMarkbook *objcMarkbook = [[BSUIRMarkbook alloc] init];
                objcMarkbook.studentNumber = [NSString stringWithUTF8String:markbook.studentNumber.c_str()];
                objcMarkbook.overallGPA = markbook.overallGPA;
                
                // Convert semesters (simplified for now)
                NSMutableArray<BSUIRSemester*> *semesters = [[NSMutableArray alloc] init];
                for (const auto& semester : markbook.semesters) {
                    BSUIRSemester *objcSemester = [[BSUIRSemester alloc] init];
                    objcSemester.number = semester.number;
                    objcSemester.gpa = semester.gpa;
                    
                    NSMutableArray<BSUIRSubject*> *subjects = [[NSMutableArray alloc] init];
                    for (const auto& subject : semester.subjects) {
                        BSUIRSubject *objcSubject = [[BSUIRSubject alloc] init];
                        objcSubject.name = [NSString stringWithUTF8String:subject.name.c_str()];
                        objcSubject.hours = subject.hours;
                        objcSubject.credits = subject.credits;
                        objcSubject.controlForm = [NSString stringWithUTF8String:subject.controlForm.c_str()];
                        objcSubject.grade = subject.grade.has_value() ? @(subject.grade.value()) : nil;
                        objcSubject.retakes = subject.retakes;
                        objcSubject.averageGrade = subject.averageGrade.has_value() ? @(subject.averageGrade.value()) : nil;
                        objcSubject.retakeChance = subject.retakeChance;
                        objcSubject.isOnline = subject.isOnline;
                        
                        [subjects addObject:objcSubject];
                    }
                    objcSemester.subjects = subjects;
                    [semesters addObject:objcSemester];
                }
                objcMarkbook.semesters = semesters;
                
                completion(objcMarkbook, nil);
            } else if (result.error.has_value()) {
                const auto& apiError = result.error.value();
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:apiError.code 
                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:apiError.message.c_str()]}];
                completion(nil, error);
            } else {
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:BSUIRAPIErrorUnknown 
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to get markbook"}];
                completion(nil, error);
            }
        });
    });
}

- (void)getGroupInfoWithCompletion:(BSUIRGroupInfoCompletion)completion {
    if (!completion) return;
    
    _apiService->getGroupInfo([completion](const BSUIR::ApiResult<BSUIR::GroupInfo>& result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success && result.data.has_value()) {
                const auto& groupInfo = result.data.value();
                
                BSUIRGroupInfo *objcGroupInfo = [[BSUIRGroupInfo alloc] init];
                objcGroupInfo.number = [NSString stringWithUTF8String:groupInfo.number.c_str()];
                objcGroupInfo.faculty = [NSString stringWithUTF8String:groupInfo.faculty.c_str()];
                objcGroupInfo.course = groupInfo.course;
                
                BSUIRCurator *curator = [[BSUIRCurator alloc] init];
                curator.fullName = [NSString stringWithUTF8String:groupInfo.curator.fullName.c_str()];
                curator.phone = [NSString stringWithUTF8String:groupInfo.curator.phone.c_str()];
                curator.email = [NSString stringWithUTF8String:groupInfo.curator.email.c_str()];
                curator.profileUrl = [NSString stringWithUTF8String:groupInfo.curator.profileUrl.c_str()];
                objcGroupInfo.curator = curator;
                
                NSMutableArray<BSUIRGroupStudent*> *students = [[NSMutableArray alloc] init];
                for (const auto& student : groupInfo.students) {
                    BSUIRGroupStudent *objcStudent = [[BSUIRGroupStudent alloc] init];
                    objcStudent.number = student.number;
                    objcStudent.fullName = [NSString stringWithUTF8String:student.fullName.c_str()];
                    [students addObject:objcStudent];
                }
                objcGroupInfo.students = students;
                
                completion(objcGroupInfo, nil);
            } else if (result.error.has_value()) {
                const auto& apiError = result.error.value();
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:apiError.code 
                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:apiError.message.c_str()]}];
                completion(nil, error);
            } else {
                NSError *error = [NSError errorWithDomain:@"BSUIRAPIError" 
                                                     code:BSUIRAPIErrorUnknown 
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to get group info"}];
                completion(nil, error);
            }
        });
    });
}

#pragma mark - Token Management

- (void)setAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken {
    if (accessToken && refreshToken) {
        std::string stdAccessToken = [accessToken UTF8String];
        std::string stdRefreshToken = [refreshToken UTF8String];
        _apiService->setTokens(stdAccessToken, stdRefreshToken);
    }
}

- (NSString*)getAccessToken {
    std::string token = _apiService->getAccessToken();
    return [NSString stringWithUTF8String:token.c_str()];
}

- (NSString*)getRefreshToken {
    std::string token = _apiService->getRefreshToken();
    return [NSString stringWithUTF8String:token.c_str()];
}

@end