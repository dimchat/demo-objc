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
//  DIMServer.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/1.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>
#import <MarsGate/StarGate.h>

#import <DIMClient/DIMMessenger+Extension.h>
#import <DIMClient/DIMServerState.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMStationDelegate <NSObject>

/**
 *  Received a new data package from the station
 *
 * @param server - current station
 * @param data - data package received
 */
- (void)station:(DIMStation *)server onReceivePackage:(NSData *)data;

@optional

/**
 *  Send data package to station success
 *
 * @param server - current station
 * @param data - data package sent
 */
- (void)station:(DIMStation *)server didSendPackage:(NSData *)data;

/**
 *  Failed to send data package to station
 *
 * @param server - current station
 * @param data - data package to send
 * @param error - error information
 */
- (void)station:(DIMStation *)server sendPackage:(NSData *)data didFailWithError:(NSError *)error;

/**
 *  Callback for handshake accepted
 *
 * @param server - current station
 * @param session - new session key
 */
- (void)station:(DIMStation *)server onHandshakeAccepted:(NSString *)session;

@end

extern NSString * const kNotificationName_ServerStateChanged;

@interface DIMServer : DIMStation <DIMMessengerDelegate, SGStarDelegate, FSMDelegate> {
    
    DIMServerStateMachine *_fsm;
}

@property (strong, nonatomic, nullable) DIMUser *currentUser;

@property (strong, nonatomic, nullable) NSString *sessionKey;

@property (readonly, strong, nonatomic) id<SGStar> star;

@property (weak, nonatomic) id<DIMStationDelegate> delegate;

- (void)handshakeWithSession:(nullable NSString *)session;
- (void)handshakeAccepted:(BOOL)success;

#pragma mark -

- (void)startWithOptions:(nullable NSDictionary *)launchOptions;
- (void)end;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
