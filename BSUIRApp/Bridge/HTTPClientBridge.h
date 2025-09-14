//
//  HTTPClientBridge.h
//  BSUIRApp HTTP Client Objective-C++ Bridge
//
//  Bridge for using NSURLSession in C++
//

#ifndef HTTPClientBridge_h
#define HTTPClientBridge_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// HTTP Method enum for C++
typedef NS_ENUM(NSInteger, HTTPMethodType) {
    HTTPMethodTypeGET,
    HTTPMethodTypePOST,
    HTTPMethodTypePUT,
    HTTPMethodTypeDELETE
};

// Callback type for HTTP responses
typedef void (*HTTPResponseCallback)(const char* responseData, 
                                   int statusCode, 
                                   const char* errorMessage,
                                   void* context);

// C interface for HTTP requests
void performHTTPRequest(const char* url,
                       HTTPMethodType method,
                       const char* headers,
                       const char* body,
                       double timeout,
                       HTTPResponseCallback callback,
                       void* context);

#ifdef __cplusplus
}
#endif

#endif /* HTTPClientBridge_h */