//
//  TouchID.m
//  Paystation
//
//  Created by Oszkó Tamás on 19/03/15.
//  Copyright (c) 2015 Cellum. All rights reserved.
//

#import "TouchID.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation TouchID

+(BOOL)touchIdAvailable
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    LAContext* context = [[LAContext alloc] init];
    NSError* error;
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return YES;
    } else {
        NSLog(@"touch id canEvaluatePolicy failed, error=%@", error);
    }
    return NO;
#endif
}


+(void)evaluateTouchIdWithDescription:(NSString*)description completion:(void(^)(BOOL success, NSError *error))completion
{
#if TARGET_IPHONE_SIMULATOR
    completion(YES, nil);
#else
    LAContext* context = [[LAContext alloc] init];
    NSError* error;
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:description reply:^(BOOL success, NSError *error) {
            if(success) {
                completion(YES, nil);
            } else {
                completion(NO, error);
                NSLog(@"touch evaluatePolicy failed, error=%@", error);
            }
        }];
    } else {
        completion(NO, error);
        NSLog(@"touch id canEvaluatePolicy failed, error=%@", error);
    }
#endif
}


@end
