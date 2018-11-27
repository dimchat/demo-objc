//
//  DIMMessageContent+Audio.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent+File.h"

#import "DIMMessageContent+Audio.h"

@interface DIMMessageContent (Hacking)

@property (nonatomic) DIMMessageType type;

@end

@implementation DIMMessageContent (Audio)

- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DIMMessageType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (NSData *)audioData {
    return [self fileData];
}

@end
