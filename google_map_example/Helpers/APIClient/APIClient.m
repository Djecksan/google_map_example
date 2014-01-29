//
//  APIClient.m
//  Terema
//
//  Created by Evgenyi Tyulenev on 28.10.13.
//  Copyright (c) 2013 PoloniumArts. All rights reserved.
//
#import "APIClient.h"

@implementation APIClient

static APIClient *_instance;

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        _instance = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APP_URL]];
	});
}

+ (instancetype)client {
	return _instance;
}

#pragma mark - REST methods

- (void)       GET:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(NSDictionary *jObject))success
              fail:(void (^)(NSError *error))failure {

	[super GET:[NSString stringWithFormat:@"%@%@",APP_URL, url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        [self logWithObject:responseObject];
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
             failure([self generateError:operation error:error]);
         }
         [self logWithObject:error];
	 }];
}

- (void)      POST:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(id jObject))success
              fail:(void (^)(NSError *error))failure {
    
	[super POST:[NSString stringWithFormat:@"%@%@", APP_URL, url] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        [self logWithObject:responseObject];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
         if (failure) {
             failure([self generateError:operation error:error]);
         }
        
         [self logWithObject:error];
    }];
}

- (void)      DELETE:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(void))success
                fail:(void (^)(NSError *error))failure {
    [super DELETE:[NSString stringWithFormat:@"%@%@", APP_URL, url] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
        [self logWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self generateError:operation error:error]);
        }
        
        [self logWithObject:error];
    }];
}

-(void)       PUT:(NSString *)url
       parameters:(NSDictionary *)parameters
          success:(void (^)(id json))success
             fail:(void (^)(NSError *error))failure {
    [self PUT:[NSString stringWithFormat:@"%@%@", APP_URL, url] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        [self logWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self generateError:operation error:error]);
        }
        
        [self logWithObject:error];
    }];
}

#pragma mark - errors generator

-(NSError *)generateError : (AFHTTPRequestOperation *)operation error: (NSError*) error {
    
    NSString *message = @"";
    if (operation.response.statusCode == 401 || operation.response.statusCode == 400) {
        @try {
            message = operation.responseObject[@"error"];
        }
        @catch (NSException *exception) {
            message = @"Придумать текст";
        }
    } else if (operation.response.statusCode > 401) {
        message = @"Возникла ошибка при обращении к сети. Повторите попытку позже.";
    } else if ([error.domain isEqualToString:@"NSURLErrorDomain"] || operation.response.statusCode >= 500) {
        message = @"Сервер не доступен, повторите попытку позже";
    }
    return [[NSError alloc] initWithDomain:error.domain code:operation.response.statusCode userInfo:@{@"message":message}];
}

#pragma mark - log

- (void)logWithObject:(id)object {
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%@", object);
#endif
}

@end
