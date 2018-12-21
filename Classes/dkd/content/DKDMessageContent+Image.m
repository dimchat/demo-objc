//
//  DKDMessageContent+Image.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DKDMessageContent+File.h"

#import "DKDMessageContent+Image.h"

@interface DKDMessageContent (Hacking)

@property (nonatomic) DKDMessageType type;

@end

@implementation DKDMessageContent (Image)

- (instancetype)initWithImageData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DKDMessageType_Image;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)imageData {
    return [self fileData];
}

- (NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

@end
