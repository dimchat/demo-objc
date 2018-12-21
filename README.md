# Decentralized Instant Messaging Client (Objective-C)

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/moky/dimc-objc/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/alpha-0.1.0-red.svg)](https://github.com/moky/dimc-objc/archive/master.zip)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/moky/dimc-objc/pulls)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20OSX%20%7C%20watchOS%20%7C%20tvOS-brightgreen.svg)](https://github.com/moky/dimc-objc/wiki)

## User & Contacts:

* Implements your entity delegate (.h/.m)

```objc
#import "DIMCore.h"

@interface Facebook : NSObject <DIMUserDataSource,
                                DIMUserDelegate,
                                DIMContactDelegate,
                                //-
                                DIMGroupDataSource,
                                DIMGroupDelegate,
                                //-
                                DIMEntityDataSource,
                                DIMProfileDataSource>

@end
```
```objc
#import "Facebook.h"

@implementation Facebook

#pragma mark - DIMUserDataSource

// get contacts count
- (NSInteger)numberOfContactsInUser:(const DIMUser *)usr {
    // TODO: load data from local storage
    // ...
    return 0;
}

// get contact ID with index
- (DIMID *)user:(const DIMUser *)usr contactAtIndex:(NSInteger)index {
    // TODO: load data from local storage
    // ...
    return nil;
}

#pragma mark DIMUserDelegate

// User factory
- (DIMUser *)userWithID:(const DIMID *)ID {
    DIMUser *user = nil;
    
    // create with ID and public key
    DIMPublicKey *PK = MKMPublicKeyForID(ID);
    if (PK) {
        user = [[DIMUser alloc] initWithID:ID publicKey:PK];
    } else {
        NSAssert(false, @"failed to get PK for user: %@", ID);
    }
    
    // add contacts
    NSInteger count = [self numberOfContactsInUser:user];
    for (NSInteger index = 0; index < count; ++index) {
        [user addContact:[self user:user contactAtIndex:index]];
    }
    
    return user;
}

#pragma mark DIMContactDelegate

// Contact factory
- (DIMContact *)contactWithID:(const DIMID *)ID {
    DIMContact *contact = nil;
    
    // create with ID and public key
    DIMPublicKey *PK = MKMPublicKeyForID(ID);
    if (PK) {
        contact = [[DIMContact alloc] initWithID:ID publicKey:PK];
    } else {
        NSAssert(false, @"failed to get PK for user: %@", ID);
    }
    
    return contact;
}

#pragma mark - DIMGroupDataSource

// get group founder
- (DIMID *)founderForGroupID:(const DIMID *)ID {
    // TODO: load data from local storage
    // ...
    return nil;
}

// get group owner
- (DIMID *)ownerForGroupID:(const DIMID *)ID {
    // TODO: load data from local storage
    // ...
    return nil;
}

// get members count
- (NSInteger)numberOfMembersInGroup:(const DIMGroup *)grp {
    // TODO: load data from local storage
    // ...
    return 0;
}

// get member at index
- (DIMID *)group:(const DIMGroup *)grp memberAtIndex:(NSInteger)index {
    // TODO: load data from local storage
    // ...
    return nil;
}

#pragma mark DIMGroupDelegate

// Group factory
- (DIMGroup *)groupWithID:(const DIMID *)ID {
    DIMGroup *group = nil;
    
    // get founder of this group
    DIMID *founder = [self founderForGroupID:ID];
    if (!founder) {
        NSAssert(false, @"founder not found for group: %@", ID);
        return  nil;
    }
    
    // create it
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[DIMPolylogue alloc] initWithID:ID founderID:founder];
    } else {
        NSAssert(false, @"group error: %@", ID);
    }
    // set owner
    group.owner = [self ownerForGroupID:ID];
    // add members
    NSInteger count = [self numberOfMembersInGroup:group];
    NSInteger index;
    for (index = 0; index < count; ++index) {
        [group addMember:[self group:group memberAtIndex:index]];
    }
    
    return group;
}

#pragma mark - DIMEntityDataSource

// get meta to create entity
- (DIMMeta *)metaForEntityID:(const DIMID *)ID {
    DIMMeta *meta = [MKMFacebook() loadMetaForEntityID:ID];
    if (meta) {
        return meta;
    }
    
    // TODO: query meta from network
    // ...
    return meta;
}

#pragma mark - DIMProfileDataSource

// get profile for entity
- (DIMProfile *)profileForID:(const DIMID *)ID {
    // TODO: load profile from local storage or network
    // ...
    return nil;
}

@end
```

### Samples
* Register User

```objc
// generate asymmetric keys
DIMPrivateKey *SK = [[DIMPrivateKey alloc] init];
DIMPublicKey *PK = SK.publicKey;

// register user
DIMUser *moky = [DIMUser registerWithName:@"moky" privateKey:SK publicKey:PK];
NSLog(@"my new ID: %@", moky.ID);

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. The private key of the registered user will save into the Keychain automatically.
2. The meta & history of this user must be saved by the entity delegate after registered.

* Load User

```objc
DIMBarrack *barrack = [DIMBarrack sharedInstance];
DIMClient  *client  = [DIMClient sharedInstance];

// 1. initialize your delegate first
_facebook = [[Facebook alloc] init];
barrack.userDelegate      = _facebook;
barrack.contactDelegate.  = _facebook;
barrack.entityDataSource  = _facebook;
barrack.profileDataSource = _facebook;

// 2. load user from barrack
NSString *str = @"moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk";  // from your db
DIMID *ID = [[DIMID alloc] initWithString:str];
DIMUser *moky = [barrack userWithID:ID];

// 3. set current user for the DIM client
client.currentUser = moky;
```
1. Your delegate must load the user data from local storage to create user,
2. After that it should try to query the newest history & profile from the network.

* Load Contact

```objc
DIMBarrack *barrack = [DIMBarrack sharedInstance];

// 1. get contacts (IDs) from local storage
DIMID *ID1 = [[DIMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
DIMID *ID2 = [[DIMID alloc] initWithString:MKM_MONKEY_KING_ID];

// 2. create contacts from barrack
DIMContact *hulk = [barrack contactWithID:ID1];
DIMContact *moki = [barrack contactWithID:ID2];

// 3. add contacts (IDs) to the user
[moky addContact:hulk.ID];
[moky addContact:moki.ID];
```
1. Your delegate must load the account data from local storage (or query from network) for creating contacts.
2. You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Implements a Station instance (.h/.m) for network transferring

```objc
#import "DIMCore.h"

@interface Station : DIMStation <DIMStationDelegate>

@end
```
```objc
#import "Station.h"

@implementation Station

#pragma mark DIMTransceiverDelegate

// send out a data package onto network
- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(nullable DIMTransceiverCompletionHandler)handler {
    // TODO: compress (if need) before sending out
    //       after that, call the completion handler with error message
    
    NSError *error;
    !handler ?: handler(error);
    
    return NO;
}

#pragma mark DIMStationDelegate

// received a new data package from the station
- (void)station:(const DIMStation *)station didReceiveData:(const NSData *)data {
    // TODO: decompress (if need) before calling Transceiver
    
    // 1. get instant message from received data
    DIMInstantMessage *iMsg;
    iMsg = [[DIMTransceiver sharedInstance] messageFromReceivedPackage:data];
    
    // 2. user-defined command
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *cmd = content.command;
        
        // TODO: parse & execute user-defined command
        // ...
        return;
    }
    
    // 3. call Amanuensis to save the instant message
    [[DIMAmanuensis sharedInstance] saveMessage:iMsg];
}

@end
```
1. You should maintain a long TCP connection to the station.
2. If connection lost, you should try ASAP to reconnect (or send data via HTTP connection).

* Implements the conversation data source & delegate (.h/.m)

```objc
#import "DIMCore.h"

@interface MessageProcessor : NSObject <DIMConversationDataSource, DIMConversationDelegate>

@end
```
```objc
#import "MessageProcessor.h"

@implementation MessageProcessor

#pragma mark DIMConversationDataSource

// get message count in the conversation
- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatBox {
    DIMID *ID = chatBox.ID;
    
    // TODO: load data from local storage
    // ...
    return 0;
}

// get message at index of the conversation
- (DIMInstantMessage *)conversation:(const DIMConversation *)chatBox messageAtIndex:(NSInteger)index {
    DIMID *ID = chatBox.ID;
    
    // TODO: load data from local storage
    // ...
    return nil;
}

#pragma mark DIMConversationDelegate

// Conversation factory
- (DIMConversation *)conversationWithID:(const DIMID *)ID {
    DIMEntity *entity = nil;
    if (MKMNetwork_IsPerson(ID.type)) {
        entity = MKMContactWithID(ID);
    } else if (MKMNetwork_IsGroup(ID.type)) {
        entity = MKMGroupWithID(ID);
    }
    
    if (entity) {
        // create new conversation with entity (Account/Group)
        return [[DIMConversation alloc] initWithEntity:entity];
    }
    NSAssert(false, @"failed to create conversation with ID: %@", ID);
    return nil;
}

// save the new message to local storage
- (BOOL)conversation:(const DIMConversation *)chatBox insertMessage:(const DIMInstantMessage *)iMsg {
    DIMID *ID = chatBox.ID;
    
    // system command
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *cmd = content.command;
        
        // TODO: parse & execute system command
        // ...
        return YES;
    }
    
    // TODO: save message in local storage,
    //       if the chat box is visiable, call it to reload data
    // ...
    return YES;
}

@end
```
1. Your message processor should implement saving new message and loading messages from local store.

### Samples
* Send message

```objc
DIMClient *client = [DIMClient sharedInstance];
DIMTransceiver *trans = [DIMTransceiver sharedInstance];

// 1. connect to a Station
Station *server = [[Station alloc] initWithHost:@"127.0.0.1" port:9394];
client.currentStation = server;
trans.delegate        = server;

// 2. create message content
NSString *text = @"Hey boy!"
DIMMessageContent *content = [[DIMMessageContent alloc] initWithText:text];
DIMID *sender = client.currentUser.ID;
DIMID *receiver = hulk.ID;

// 3. call transceiver to send out message content
[trans sendMessageContent:content 
                     from:sender
                       to:receiver
                 callback:^(const DIMReliableMessage *rMsg, const NSError * _Nullable error) {
                     if (error) {
                         // TODO: 3.1 process error callback
                     } else {
                         // TODO: 3.2 process success callback
                     }
                 }];
```

* Receive message

```objc
// create your message processor
_myMessageProcessor = [[MessageProcessor alloc] init];

// set to the conversation manager
DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
clerk.dataSource = _myMessageProcessor;
clerk.delegate   = _myMessageProcessor;

// NOTICE:
//     1. when your network connection received a message data from station,
//        you should decompress(if need) and call the Transceiver to verify
//        and decrypt it to an instant message;
//     2. after that, you could try to recognize the message type, if it is
//        a system command, you could run your scripts for it, otherwise
//        call the Amanuensis to handle the message;
//     3. the Amanuensis will insert it into the chat box (Conversation)
//        that the message belongs to;
//     4. finally, the chat box will call your message processor to save it,
//        the Amanuensis will set your message processor into each chat box
//        automatically, unless you have already specify them.
```

---
Written by [Albert Moky](http://moky.github.com/) @2018
