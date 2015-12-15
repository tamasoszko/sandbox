//
//  Crypto.m
//  NetBank
//
//  Created by Oszkó Tamás on 05/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

#import "Crypto.h"
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/objects.h>
#import <openssl/rand.h>
#import <openssl/rsa.h>

@implementation Crypto

+(NSInteger)keyLengthAes256
{
    return kCCKeySizeAES256;
}

+(NSData*)generateRandomBytes:(NSInteger)length
{
    NSMutableData * result = [[NSMutableData alloc] initWithLength:length];
    RAND_poll();
    RAND_bytes(result.mutableBytes, (int)result.length);
    return result;
}

+(NSData*) sha256:(NSData*)data{
    NSMutableData * result = [[NSMutableData alloc] initWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (int)data.length, result.mutableBytes);
    return result;
}

+(NSData*)decryptData:(NSData*)data withKey:(NSData*)key{
    return [self cryptData:data withKey:key mode:kCCDecrypt];
}

+(NSData*)encryptData:(NSData*)data withKey:(NSData*)key{
    return [self cryptData:data withKey:key mode:kCCEncrypt];
}

+(NSData*)cryptData:(NSData*)data withKey:(NSData*)key mode:(int)mode{
    
    NSMutableData* result = [[NSMutableData alloc] initWithLength:data.length + kCCBlockSizeAES128 - (data.length % kCCBlockSizeAES128)];
    size_t cryptedBytesCount = -1;
    CCCryptorStatus status = CCCrypt(mode, kCCAlgorithmAES, kCCOptionPKCS7Padding, key.bytes, key.length, NULL, data.bytes, data.length, result.mutableBytes, result.length, &cryptedBytesCount);
    
    if(status == kCCSuccess) {
        result.length = cryptedBytesCount;
        return result;
    } else {
        return nil;
    }
}


@end
