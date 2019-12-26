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
//  DIMCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMMessenger.h"

#import "DIMMetaCommandProcessor.h"
#import "DIMProfileCommandProcessor.h"

#import "DIMCommandProcessor.h"

@interface DIMCommandProcessor () {
    
    NSMutableDictionary<NSString *, DIMCommandProcessor *> *_processors;
}

@end

@interface DIMCommandProcessor (Create)

- (DIMCommandProcessor *)processorForCommand:(NSString *)name;

@end

static inline void load_cpu_classes(void) {
    // meta
    [DIMCommandProcessor registerClass:[DIMMetaCommandProcessor class]
                            forCommand:DIMCommand_Meta];
    // profile
    [DIMCommandProcessor registerClass:[DIMProfileCommandProcessor class]
                            forCommand:DIMCommand_Profile];
}

@implementation DIMCommandProcessor

- (instancetype)initWithMessenger:(DIMMessenger *)messenger {
    if (self = [super initWithMessenger:messenger]) {
        _processors = nil;
        
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cpu_classes();
        });
    }
    return self;
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([self isMemberOfClass:[DIMCommandProcessor class]], @"error!");
    NSAssert([content isKindOfClass:[DIMCommand class]], @"command error: %@", content);
    // process command content by name
    DIMCommand *cmd = (DIMCommand *)content;
    DIMCommandProcessor *cpu = [self processorForCommand:cmd.command];
    if (cpu) {
        NSAssert(cpu != self, @"Dead cycle!");
        return [cpu processContent:content sender:sender message:iMsg];
    }
    NSString *text = [NSString stringWithFormat:@"Command (%@) not support yet!", cmd.command];
    return [[DIMTextContent alloc] initWithText:text];
}

@end

static NSMutableDictionary<NSString *, Class> *cpu_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // ...
    });
    return classes;
}

@implementation DIMCommandProcessor (Runtime)

+ (void)registerClass:(Class)clazz forCommand:(NSString *)name {
    NSAssert(![clazz isEqual:self], @"only subclass");
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [cpu_classes() setObject:clazz forKey:name];
    } else {
        [cpu_classes() removeObjectForKey:name];
    }
}

- (DIMContentProcessor *)processorForCommand:(NSString *)name {
    SingletonDispatchOnce(^{
        self->_processors = [[NSMutableDictionary alloc] init];
    });
    DIMCommandProcessor *cpu = [_processors objectForKey:name];
    if (!cpu) {
        // try to create new processor with content type
        Class clazz = [cpu_classes() objectForKey:name];
        if (clazz) {
            cpu = [[clazz alloc] initWithMessenger:_messenger];
            [_processors setObject:cpu forKey:name];
        }
    }
    return cpu;
}

@end

