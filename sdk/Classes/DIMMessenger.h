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
//  DIMMessenger.h
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Callback for sending message
 *  set by application and executed by DIM Core
 */
typedef void (^DIMMessengerCallback)(DIMReliableMessage *rMsg,
                                     NSError * _Nullable error);

/**
 *  Handler to call after sending package complete
 *  executed by application
 */
typedef void (^DIMMessengerCompletionHandler)(NSError * _Nullable error);

@protocol DIMMessengerDelegate <NSObject>

/**
 *  Send out a data package onto network
 *
 *  @param data - package`
 *  @param handler - completion handler
 *  @return NO on data/delegate error
 */
- (BOOL)sendPackage:(NSData *)data completionHandler:(nullable DIMMessengerCompletionHandler)handler;

/**
 *  Upload encrypted data to CDN
 *
 *  @param CT - encrypted file data
 *  @param iMsg - instant message
 *  @return download URL
 */
- (nullable NSURL *)uploadEncryptedFileData:(NSData *)CT forMessage:(DIMInstantMessage *)iMsg;

/**
 *  Download encrypted data from CDN
 *
 *  @param url - download URL
 *  @param iMsg - instant message
 *  @return encrypted file data
 */
- (nullable NSData *)downloadEncryptedFileData:(NSURL *)url forMessage:(DIMInstantMessage *)iMsg;

@end

@protocol DIMConnectionDelegate <NSObject>

/**
 *  Receive data package
 *
 * @param data - package from network connection
 * @return response to sender
 */
- (nullable NSData *)onReceivePackage:(NSData *)data;

@end

#pragma mark -

@interface DIMMessenger : DIMTransceiver <DIMConnectionDelegate>

@property (readonly, strong, nonatomic) NSDictionary *context;

@property (readonly, weak, nonatomic) DIMFacebook *facebook;
@property (weak, nonatomic) id<DIMMessengerDelegate> delegate;

@property (strong, nonatomic, nullable) NSArray<DIMUser *> *localUsers;
@property (strong, nonatomic, nullable) DIMUser *currentUser;

- (nullable id)valueForContextName:(NSString *)key;
- (void)setContextValue:(id)value forName:(NSString *)key;

- (nullable DIMUser *)selectUserWithID:(DIMID *)receiver;

@end

@interface DIMMessenger (Send)

/**
 *  Interface for client to query meta on station, or the station query on other station
 *
 * @param ID - entity ID
 * @return true on success
 */
- (BOOL)queryMetaForID:(DIMID *)ID;

/**
 *  Send message content to receiver
 *
 * @param content - message content
 * @param receiver - receiver ID
 * @return true on success
 */
- (BOOL)sendContent:(DIMContent *)content receiver:(DIMID *)receiver;

- (BOOL)sendContent:(DIMContent *)content
           receiver:(DIMID *)receiver
           callback:(nullable DIMMessengerCallback)callback
        dispersedly:(BOOL)split;

/**
 *  Send instant message (encrypt and sign) onto DIM network
 *
 *  @param iMsg - instant message
 *  @param callback - callback function
 *  @param split - if it's a group message, split it before sending out
 *  @return NO on data/delegate error
 */
- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMMessengerCallback)callback
               dispersedly:(BOOL)split;

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(nullable DIMMessengerCallback)callback;

@end

@interface DIMMessenger (Message)

/**
 * Re-pack and deliver (Top-Secret) message to the real receiver
 *
 * @param rMsg - top-secret message
 * @return receipt on success
 */
- (nullable DIMContent *)forwardMessage:(DIMReliableMessage *)rMsg;

/**
 * Deliver message to everyone@everywhere, including all neighbours
 *
 * @param rMsg - broadcast message
 * @return receipt on success
 */
- (nullable DIMContent *)broadcastMessage:(DIMReliableMessage *)rMsg;

/**
 * Deliver message to the receiver, or broadcast to neighbours
 *
 * @param rMsg - reliable message
 * @return receipt on success
 */
- (nullable DIMContent *)deliverMessage:(DIMReliableMessage *)rMsg;

/**
 * Save the message into local storage
 *
 * @param iMsg - instant message
 * @return true on success
 */
- (BOOL)saveMessage:(DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
