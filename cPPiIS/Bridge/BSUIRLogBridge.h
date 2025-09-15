#import <Foundation/Foundation.h>

// MARK: - Log Level Enumeration for Objective-C
typedef NS_ENUM(NSInteger, BSUIRLogLevel) {
    BSUIRLogLevelDebug = 0,
    BSUIRLogLevelInfo = 1,
    BSUIRLogLevelWarning = 2,
    BSUIRLogLevelError = 3,
    BSUIRLogLevelSuccess = 4
};

// MARK: - Log Entry for Objective-C Bridge
@interface BSUIRLogEntry : NSObject

@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BSUIRLogLevel level;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *metadata;

- (instancetype)initWithLevel:(BSUIRLogLevel)level
                     category:(NSString *)category
                      message:(NSString *)message
                     metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

@end

// MARK: - Log Bridge Protocol
@protocol BSUIRLogBridgeDelegate <NSObject>

- (void)didReceiveLogEntry:(BSUIRLogEntry *)logEntry;

@end

// MARK: - Log Bridge Interface
@interface BSUIRLogBridge : NSObject

@property (nonatomic, weak, nullable) id<BSUIRLogBridgeDelegate> delegate;

+ (instancetype)shared;

// Swift-friendly logging methods
- (void)logWithLevel:(BSUIRLogLevel)level
            category:(NSString *)category
             message:(NSString *)message
            metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

- (void)debugWithCategory:(NSString *)category
                  message:(NSString *)message
                 metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

- (void)infoWithCategory:(NSString *)category
                 message:(NSString *)message
                metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

- (void)warningWithCategory:(NSString *)category
                    message:(NSString *)message
                   metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

- (void)errorWithCategory:(NSString *)category
                  message:(NSString *)message
                 metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

- (void)successWithCategory:(NSString *)category
                    message:(NSString *)message
                   metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata;

@end