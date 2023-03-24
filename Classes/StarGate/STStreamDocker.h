// license: https://mit-license.org
//
//  Star Gate: Network Connection Module
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  STStreamDocker.h
//  DIMClient
//
//  Created by Albert Moky on 2023/3/11.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <StarTrek/StarTrek.h>

NS_ASSUME_NONNULL_BEGIN

@interface STPlainDocker : STDocker

// protected
- (id<STArrival>)createArrivalWithData:(NSData *)pack;

// protected
- (id<STDeparture>)createDepartureWithData:(NSData *)pack priority:(NSInteger)prior;

//
//  Sending
//

- (BOOL)sendData:(NSData *)payload priority:(NSInteger)prior;

@end

@protocol STDeparturePacker <NSObject>

// packData
- (id<STDeparture>)departureByPackData:(NSData *)payload priority:(NSInteger)prior;

@end

@interface STStreamDocker : STPlainDocker <STDeparturePacker>

@end

NS_ASSUME_NONNULL_END
