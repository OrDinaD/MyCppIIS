//
//  HTTPClientBridge.mm
//  BSUIRApp HTTP Client Objective-C++ Bridge Implementation
//

#import "HTTPClientBridge.h"
#import <Foundation/Foundation.h>

// Convert C string to NSString safely
NSString* safeStringFromCString(const char* cString) {
    return cString ? [NSString stringWithUTF8String:cString] : @"";
}

// Convert NSData to C string
const char* cStringFromNSData(NSData* data) {
    if (!data) return nullptr;
    
    // Create a null-terminated string
    NSMutableData* mutableData = [data mutableCopy];
    char null = '\0';
    [mutableData appendBytes:&null length:1];
    
    // Allocate memory and copy (caller must free)
    size_t length = [mutableData length];
    char* result = (char*)malloc(length);
    memcpy(result, [mutableData bytes], length);
    
    return result;
}

// Parse headers string into NSDictionary
NSDictionary* parseHeadersString(const char* headersString) {
    if (!headersString) return @{};
    
    NSString* headers = [NSString stringWithUTF8String:headersString];
    NSMutableDictionary* headerDict = [[NSMutableDictionary alloc] init];
    
    // Simple parsing: "key1:value1|key2:value2"
    NSArray* headerPairs = [headers componentsSeparatedByString:@"|"];
    for (NSString* pair in headerPairs) {
        NSArray* keyValue = [pair componentsSeparatedByString:@":"];
        if (keyValue.count == 2) {
            NSString* key = [keyValue[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* value = [keyValue[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            headerDict[key] = value;
        }
    }
    
    return headerDict;
}

void performHTTPRequest(const char* url,
                       HTTPMethodType method,
                       const char* headers,
                       const char* body,
                       double timeout,
                       HTTPResponseCallback callback,
                       void* context) {
    
    if (!url || !callback) {
        if (callback) {
            callback(nullptr, 0, "Invalid parameters", context);
        }
        return;
    }
    
    // Create URL
    NSString* urlString = safeStringFromCString(url);
    NSURL* nsUrl = [NSURL URLWithString:urlString];
    
    if (!nsUrl) {
        callback(nullptr, 0, "Invalid URL", context);
        return;
    }
    
    // Create request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
    request.timeoutInterval = timeout;
    
    // Set HTTP method
    switch (method) {
        case HTTPMethodTypeGET:
            request.HTTPMethod = @"GET";
            break;
        case HTTPMethodTypePOST:
            request.HTTPMethod = @"POST";
            break;
        case HTTPMethodTypePUT:
            request.HTTPMethod = @"PUT";
            break;
        case HTTPMethodTypeDELETE:
            request.HTTPMethod = @"DELETE";
            break;
    }
    
    // Set headers
    NSDictionary* headerDict = parseHeadersString(headers);
    for (NSString* key in headerDict) {
        [request setValue:headerDict[key] forHTTPHeaderField:key];
    }
    
    // Set body
    if (body && strlen(body) > 0) {
        NSString* bodyString = safeStringFromCString(body);
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // Create session
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    // Perform request
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request 
                                            completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        int statusCode = 0;
        const char* responseData = nullptr;
        const char* errorMessage = nullptr;
        
        if (error) {
            errorMessage = [[error localizedDescription] UTF8String];
        } else {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                statusCode = (int)httpResponse.statusCode;
            }
            
            if (data) {
                responseData = cStringFromNSData(data);
            }
        }
        
        // Call the callback
        callback(responseData, statusCode, errorMessage, context);
        
        // Free allocated memory for response data
        if (responseData) {
            free((void*)responseData);
        }
    }];
    
    [task resume];
}