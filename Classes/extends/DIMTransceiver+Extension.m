//
//  DIMTransceiver+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFacebook.h"

#import "DIMTransceiver+Extension.h"

@implementation DIMTransceiver (Extension)

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _keyStore = [[DIMKeyStore alloc] init];
        
        _barrackDelegate = [DIMFacebook sharedInstance];
        _entityDataSource = [DIMFacebook sharedInstance];
        _cipherKeyDataSource = _keyStore;
        
        // register all content classes
        [DIMContent loadContentClasses];
    }
    return self;
}

static DIMKeyStore *_keyStore;

- (DIMKeyStore *)keyStore {
    return _keyStore;
}

@end
