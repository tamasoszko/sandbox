//
//  Keychain.h
//  Paystation
//
//  Created by Oszkó Tamás on 19/03/15.
//  Copyright (c) 2015 Cellum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject

-(instancetype)initWithName:(NSString*)name;
-(void)saveData:(NSString*)data;
-(void)deleteData;
-(NSString*)loadData;


@end
