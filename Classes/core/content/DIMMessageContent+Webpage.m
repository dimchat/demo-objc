//
//  DIMMessageContent+Webpage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMMessageContent+Webpage.h"

@implementation DIMMessageContent (Webpage)

- (instancetype)initWithURLString:(const NSString *)url
                            title:(nullable const NSString *)title
                      description:(nullable const NSString *)desc
                             icon:(nullable const NSData *)icon {
    if (self = [self initWithType:DIMMessageType_Page]) {
        // url
        [_storeDictionary setObject:url forKey:@"URL"];
        
        // title
        if (title) {
            [_storeDictionary setObject:title forKey:@"title"];
        }
        
        // desc
        if (desc) {
            [_storeDictionary setObject:desc forKey:@"desc"];
        }
        
        // icon
        if (icon) {
            NSString *str = [icon base64Encode];
            [_storeDictionary setObject:str forKey:@"icon"];
        }
    }
    return self;
}

- (NSString *)title {
    return [_storeDictionary objectForKey:@"title"];
}

- (NSString *)desc {
    return [_storeDictionary objectForKey:@"desc"];
}

- (NSData *)icon {
    NSString *str = [_storeDictionary objectForKey:@"icon"];
    return [str base64Decode];
}

@end
