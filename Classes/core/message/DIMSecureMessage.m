//
//  DIMSecureMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMSecureMessage.h"

@interface DIMSecureMessage ()

@property (strong, nonatomic) const MKMSymmetricKey *scKey;

@end

@implementation DIMSecureMessage

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to {
    const MKMSymmetricKey *key = nil;
    self = [self initWithContent:content
                          sender:from
                        receiver:to
                             key:key];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to
                            key:(const MKMSymmetricKey *)key {
    self = [super initWithContent:content
                           sender:from
                         receiver:to];
    if (self) {
        self.scKey = key;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        id scKey = [dict objectForKey:@"key"];
        if ([scKey isKindOfClass:[MKMSymmetricKey class]]) {
            self.scKey = scKey;
        } else {
            NSAssert([scKey isKindOfClass:[NSDictionary class]], @"key error");
            self.scKey = [[MKMSymmetricKey alloc] initWithDictionary:scKey];
        }
    }
    return self;
}

@end
