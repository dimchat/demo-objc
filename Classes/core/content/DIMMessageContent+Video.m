//
//  DIMMessageContent+Video.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent+File.h"

#import "DIMMessageContent+Video.h"

@interface DIMMessageContent (Hacking)

@property (nonatomic) DIMMessageType type;

@end

@implementation DIMMessageContent (Video)

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DIMMessageType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)videoData {
    return [self fileData];
}

@end
