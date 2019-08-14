//
//  DIMMessanger.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFacebook.h"
#import "DIMKeyStore.h"

#import "DIMMessanger.h"

@implementation DIMMessanger

SingletonImplementations(DIMMessanger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
        
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

@end
