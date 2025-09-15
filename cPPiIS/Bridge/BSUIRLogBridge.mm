#import "BSUIRLogBridge.h"

// MARK: - Log Entry Implementation
@implementation BSUIRLogEntry

- (instancetype)initWithLevel:(BSUIRLogLevel)level
                     category:(NSString *)category
                      message:(NSString *)message
                     metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    self = [super init];
    if (self) {
        _timestamp = [NSDate date];
        _level = level;
        _category = category ?: @"General";
        _message = message ?: @"";
        _metadata = metadata;
    }
    return self;
}

@end

// MARK: - Log Bridge Implementation
@implementation BSUIRLogBridge

+ (instancetype)shared {
    static BSUIRLogBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BSUIRLogBridge alloc] init];
    });
    return sharedInstance;
}

- (void)logWithLevel:(BSUIRLogLevel)level
            category:(NSString *)category
             message:(NSString *)message
            metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    
    BSUIRLogEntry *logEntry = [[BSUIRLogEntry alloc] initWithLevel:level
                                                          category:category
                                                           message:message
                                                          metadata:metadata];
    
    // Notify delegate on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveLogEntry:)]) {
            [self.delegate didReceiveLogEntry:logEntry];
        }
    });
    
    // Also log to NSLog for debugging
    NSString *levelString = [self stringForLogLevel:level];
    NSString *metadataString = @"";
    
    if (metadata && metadata.count > 0) {
        NSMutableArray *pairs = [NSMutableArray array];
        for (NSString *key in metadata.allKeys) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, metadata[key]]];
        }
        metadataString = [NSString stringWithFormat:@" [%@]", [pairs componentsJoinedByString:@", "]];
    }
    
    NSLog(@"[%@] %@: %@%@", levelString, category, message, metadataString);
}

- (void)debugWithCategory:(NSString *)category
                  message:(NSString *)message
                 metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    [self logWithLevel:BSUIRLogLevelDebug category:category message:message metadata:metadata];
}

- (void)infoWithCategory:(NSString *)category
                 message:(NSString *)message
                metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    [self logWithLevel:BSUIRLogLevelInfo category:category message:message metadata:metadata];
}

- (void)warningWithCategory:(NSString *)category
                    message:(NSString *)message
                   metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    [self logWithLevel:BSUIRLogLevelWarning category:category message:message metadata:metadata];
}

- (void)errorWithCategory:(NSString *)category
                  message:(NSString *)message
                 metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    [self logWithLevel:BSUIRLogLevelError category:category message:message metadata:metadata];
}

- (void)successWithCategory:(NSString *)category
                    message:(NSString *)message
                   metadata:(nullable NSDictionary<NSString *, NSString *> *)metadata {
    [self logWithLevel:BSUIRLogLevelSuccess category:category message:message metadata:metadata];
}

#pragma mark - Private Methods

- (NSString *)stringForLogLevel:(BSUIRLogLevel)level {
    switch (level) {
        case BSUIRLogLevelDebug:
            return @"DEBUG";
        case BSUIRLogLevelInfo:
            return @"INFO";
        case BSUIRLogLevelWarning:
            return @"WARNING";
        case BSUIRLogLevelError:
            return @"ERROR";
        case BSUIRLogLevelSuccess:
            return @"SUCCESS";
        default:
            return @"UNKNOWN";
    }
}

@end