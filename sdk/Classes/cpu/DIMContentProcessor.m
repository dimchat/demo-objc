// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMContentProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFacebook.h"
#import "DIMMessenger.h"

#import "DIMCommandProcessor.h"
#import "DIMHistoryProcessor.h"
#import "DIMDefaultProcessor.h"

#import "DIMContentProcessor.h"

@interface DIMContentProcessor () {
    
    NSMutableDictionary<NSString *, id> *_context;
    
    NSMutableDictionary<NSNumber *, DIMContentProcessor *> *_processors;
}

@property (weak, nonatomic) DIMMessenger *messenger;

@end

@interface DIMContentProcessor (Create)

- (DIMContentProcessor *)processorForContentType:(DKDContentType)type;

@end

static inline void load_cpu_classes(void) {
    [DIMContentProcessor registerClass:[DIMCommandProcessor class] forType:DKDContentType_Command];
    [DIMContentProcessor registerClass:[DIMHistoryCommandProcessor class] forType:DKDContentType_History];
    [DIMContentProcessor registerClass:[DIMDefaultProcessor class] forType:DKDContentType_Unknown];
}

@implementation DIMContentProcessor

- (instancetype)initWithMessenger:(DIMMessenger *)messenger {
    if (self = [super init]) {
        _messenger = messenger;
        _facebook = messenger.facebook;
        
        _context = [[NSMutableDictionary alloc] init];
        _processors = nil;
        
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cpu_classes();
        });
    }
    return self;
}

- (NSDictionary *)context {
    return _context;
}

- (DIMFacebook *)facebook {
    return _facebook;
}

- (nullable id)valueForContextName:(NSString *)key {
    return [_messenger valueForContextName:key];
}

- (void)setContextValue:(id)value forName:(NSString *)key {
    [_messenger setContextValue:value forName:key];
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([self isMemberOfClass:[DIMContentProcessor class]], @"error!");
    // process content by type
    DIMContentProcessor *cpu = [self processorForContentType:content.type];
    NSAssert(cpu != self, @"Dead cycle!");
    return [cpu processContent:content sender:sender message:iMsg];
}

@end

static NSMutableDictionary<NSNumber *, Class> *cpu_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // ...
    });
    return classes;
}

@implementation DIMContentProcessor (Runtime)

+ (void)registerClass:(nullable Class)clazz forType:(DKDContentType)type {
    NSAssert(![clazz isEqual:self], @"only subclass");
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [cpu_classes() setObject:clazz forKey:@(type)];
    } else {
        [cpu_classes() removeObjectForKey:@(type)];
    }
}

- (DIMContentProcessor *)processorForContentType:(DKDContentType)type {
    SingletonDispatchOnce(^{
        _processors = [[NSMutableDictionary alloc] init];
    });
    NSNumber *key = @(type);
    DIMContentProcessor *cpu = [_processors objectForKey:key];
    if (!cpu) {
        // try to create new processor with content type
        Class clazz = [cpu_classes() objectForKey:key];
        if (!clazz) {
            clazz = [cpu_classes() objectForKey:@(DKDContentType_Unknown)];
            NSAssert(clazz, @"default CPU not set");
        }
        cpu = [[clazz alloc] initWithMessenger:_messenger];
        [_processors setObject:cpu forKey:@(type)];
    }
    return cpu;
}

@end
