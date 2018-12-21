//
//  DKDMessageContent+Audio.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent+File.h"

#import "DKDMessageContent+Audio.h"

@interface DKDMessageContent (Hacking)

@property (nonatomic) DKDMessageType type;

@end

@implementation DKDMessageContent (Audio)

- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DKDMessageType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (NSData *)audioData {
    return [self fileData];
}

@end
