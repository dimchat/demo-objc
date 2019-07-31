//
//  DIMTransceiver+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMAddress+Extension.h"
#import "MKMMeta+Extension.h"

#import "DIMFacebook.h"

#import "DIMTransceiver+Extension.h"

@implementation DIMTransceiver (Extension)

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _keyStore = [[DIMKeyStore alloc] init];
        
        _barrack = [DIMFacebook sharedInstance];
        _cipherKeyDataSource = _keyStore;
        
        // register all content classes
        [DIMContent loadContentClasses];
        
        // register new address classes
        [MKMAddress registerClass:[MKMAddressETH class]];
        
        // register new meta classes
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_BTC];
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_ExBTC];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ETH];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ExETH];
    }
    return self;
}

static DIMKeyStore *_keyStore;

@end
