//
//  DIMMessageContent+File.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMMessageContent+File.h"

@implementation DIMMessageContent (File)

- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name {
    if (self = [self initWithType:DIMMessageType_File]) {
        // url or data
        NSString *url = [self.delegate URLStringForFileData:data
                                                   filename:name];
        if (url) {
            [_storeDictionary setObject:url forKey:@"URL"];
        } else {
            NSString *str = [data base64Encode];
            [_storeDictionary setObject:str forKey:@"data"];
        }
        
        // filename
        if (name) {
            [_storeDictionary setObject:name forKey:@"filename"];
        }
    }
    return self;
}

- (NSURL *)URL {
    NSString *string = [_storeDictionary objectForKey:@"URL"];
    if (string) {
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (NSData *)fileData {
    NSString *str = [_storeDictionary objectForKey:@"data"];
    if (str) {
        return [str base64Decode];
    }
    NSURL *url = [self URL];
    if (url) {
        // TODO: download file from the URL
    }
    return nil;
}

- (NSString *)filename {
    return [_storeDictionary objectForKey:@"filename"];
}

@end
