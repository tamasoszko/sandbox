//
//  TouchID.h
//  Paystation
//
//  Created by Oszkó Tamás on 19/03/15.
//  Copyright (c) 2015 Cellum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchID : NSObject

+(BOOL)touchIdAvailable;
+(void)evaluateTouchIdWithDescription:(NSString*)description completion:(void(^)(BOOL success, NSError *error))completion;

@end
