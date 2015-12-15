//
//  Keychain.m
//  Paystation
//
//  Created by Oszkó Tamás on 19/03/15.
//  Copyright (c) 2015 Cellum. All rights reserved.
//

#import "Keychain.h"
#import "KeychainItemWrapper.h"

@interface Keychain()
@property(nonatomic) KeychainItemWrapper* keychain;
@end

@implementation Keychain

-(instancetype)initWithName:(NSString*)name
{
    if(self = [super init]) {
        _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:name accessGroup:nil];
    }
    return self;
}

-(void)saveData:(NSString *)data
{
    [self.keychain setObject:(__bridge id)(kSecAttrAccessibleWhenUnlockedThisDeviceOnly) forKey:(__bridge id)(kSecAttrAccessible)];
    [self.keychain setObject:data forKey:(__bridge id)(kSecValueData)];
}

-(void)deleteData
{
    [self.keychain resetKeychainItem];
}

-(NSString*)loadData
{
    return [self.keychain objectForKey:(__bridge id)(kSecValueData)];
}


@end
