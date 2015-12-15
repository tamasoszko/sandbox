//
//  Crypto.h
//  NetBank
//
//  Created by Oszkó Tamás on 05/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crypto : NSObject

+(NSInteger)keyLengthAes256;

+(NSData*)generateRandomBytes:(NSInteger)length;
+(NSData*)sha256:(NSData*)data;
+(NSData*)decryptData:(NSData*)data withKey:(NSData*)key;
+(NSData*)encryptData:(NSData*)data withKey:(NSData*)key;

@end
