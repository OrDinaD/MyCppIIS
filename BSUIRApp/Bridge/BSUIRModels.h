//
//  BSUIRModels.h
//  BSUIRApp Objective-C Models for Swift Interoperability
//

#ifndef BSUIRModels_h
#define BSUIRModels_h

#import <Foundation/Foundation.h>

// User model
@interface BSUIRUser : NSObject
@property (nonatomic, strong) NSString* studentNumber;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* middleName;
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* refreshToken;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger expiresIn;
@end

// Personal Information model
@interface BSUIRPersonalInfo : NSObject
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString* studentNumber;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* middleName;
@property (nonatomic, strong) NSString* firstNameBel;
@property (nonatomic, strong) NSString* lastNameBel;
@property (nonatomic, strong) NSString* middleNameBel;
@property (nonatomic, strong) NSString* birthDate;
@property (nonatomic, assign) NSInteger course;
@property (nonatomic, strong) NSString* faculty;
@property (nonatomic, strong) NSString* speciality;
@property (nonatomic, strong) NSString* group;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* phone;
@end

// Subject model
@interface BSUIRSubject : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) double hours;
@property (nonatomic, assign) NSInteger credits;
@property (nonatomic, strong) NSString* controlForm;
@property (nonatomic, strong) NSNumber* grade; // NSNumber for optional int
@property (nonatomic, assign) NSInteger retakes;
@property (nonatomic, strong) NSNumber* averageGrade; // NSNumber for optional double
@property (nonatomic, assign) double retakeChance;
@property (nonatomic, assign) BOOL isOnline;
@end

// Semester model
@interface BSUIRSemester : NSObject
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) double gpa;
@property (nonatomic, strong) NSArray<BSUIRSubject*>* subjects;
@end

// Markbook model
@interface BSUIRMarkbook : NSObject
@property (nonatomic, strong) NSString* studentNumber;
@property (nonatomic, assign) double overallGPA;
@property (nonatomic, strong) NSArray<BSUIRSemester*>* semesters;
@end

// Curator model
@interface BSUIRCurator : NSObject
@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* profileUrl;
@end

// Group student model
@interface BSUIRGroupStudent : NSObject
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSString* fullName;
@end

// Group info model
@interface BSUIRGroupInfo : NSObject
@property (nonatomic, strong) NSString* number;
@property (nonatomic, strong) NSString* faculty;
@property (nonatomic, assign) NSInteger course;
@property (nonatomic, strong) BSUIRCurator* curator;
@property (nonatomic, strong) NSArray<BSUIRGroupStudent*>* students;
@end

#endif /* BSUIRModels_h */