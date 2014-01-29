//
//  APIClient.h
//  Created by Evgenyi Tyulenev on 28.10.13.
//  Copyright (c) 2013 PoloniumArts. All rights reserved.

static NSString * const APP_URL = @"http://maps.googleapis.com/maps/api/directions/json?";

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface APIClient : AFHTTPRequestOperationManager

+ (instancetype)client;

- (void)       GET:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(NSDictionary *jObject))success
              fail:(void (^)(NSError *error))fileure;

- (void)      POST:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(id jObject))success
              fail:(void (^)(NSError *error))fileure;

- (void)      DELETE:(NSString *)url
          parameters:(NSDictionary *)parameters
             success:(void (^)(void))success
                fail:(void (^)(NSError *error))failure;

-(void)       PUT:(NSString *)url
       parameters:(NSDictionary *)parameters
          success:(void (^)(id json))success
             fail:(void (^)(NSError *error))failure;
@end