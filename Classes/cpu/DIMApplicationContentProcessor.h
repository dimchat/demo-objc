// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  DIMApplicationContentProcessor.h
//  DIMClient
//
//  Created by Albert Moky on 2022/8/23.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMAppContentProcessor : DIMCustomizedContentProcessor

@end

#ifdef __cplusplus
extern "C" {
#endif

id<DKDCustomizedContent> DIMAppContentCreate(NSString *app, NSString *mod, NSString *act);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark - Application Customized Content Handler

@interface DIMAppContentHandler : DIMTwinsHelper <DIMCustomizedContentHandler>

- (NSArray<id<DKDContent>> *)respondText:(NSString *)text withGroup:(nullable id<MKMID>)group;

@end

/**
 *  Drift Bottle Game
 *  ~~~~~~~~~~~~~~~~~
 *
 *  Handler for customized content
 */
@interface DIMDriftBottleHandler : DIMAppContentHandler

@end

NS_ASSUME_NONNULL_END
