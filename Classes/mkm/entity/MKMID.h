//
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMString.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMAddress;
@class MKMMeta;

/**
 *  ID for entity (User/Contact/Group/...)
 *
 *      data format: "name@address[/terminal]"
 *
 *      fileds:
 *          name     - username, any nonempty string
 *          address  - hash(signature) to identify a user
 *          terminal - login point/device, OPTIONAL
 */
@interface MKMID : MKMString

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) MKMAddress *address;
@property (readonly, nonatomic) NSUInteger number;

@property (readonly, strong, nonatomic, nullable) NSString * terminal;

@property (readonly, nonatomic, getter=isValid) BOOL valid;

+ (instancetype)IDWithID:(id)ID;

/**
 Initialize an ID with string form "name@address[/terminal]"

 @param aString - ID string
 @return ID object
 */
- (instancetype)initWithString:(NSString *)aString;

/**
 Initialize an ID with username & address

 @param seed - username
 @param addr - hash(signature)
 @return ID object
 */
- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr;

/**
 Initialize an ID with username, address & terminal

 @param seed - username
 @param addr - hash(signature)
 @param res - resource point where the user logged in
 @return ID object
 */
- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr
                    terminal:(const NSString *)res;

/**
 ID without terminal

 @return ID object
 */
- (instancetype)naked;

@end

NS_ASSUME_NONNULL_END
