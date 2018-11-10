# Decentralized Instant Messaging Client (Objective-C)

## User & Contacts:

* Implements your entity delegate (.h/.m)

```
#import "DIMC.h"

@interface Facebook : NSObject <MKMUserDelegate, MKMContactDelegate, MKMEntityDataSource, MKMProfileDataSource>

@end
```
```
#import "Facebook.h"

@implementation Facebook

#pragma mark MKMUserDelegate

// User factory
- (MKMUser *)userWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMUser alloc] initWithID:ID publicKey:PK];
}

#pragma mark MKMContactDelegate

// Contact factory
- (MKMContact *)contactWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMContact alloc] initWithID:ID publicKey:PK];
}

#pragma mark MKMEntityDataSource

// get meta to create entity
- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    NSDictionary *dict;
    // TODO: load meta from local storage or network
    // ...
    return [[MKMMeta alloc] initWithDictionary:dict];;
}

#pragma mark MKMProfileDataSource

// get profile for entity
- (MKMProfile *)profileForID:(const MKMID *)ID {
    NSDictionary *dict;
    // TODO: load profile from local storage or network
    // ...
    return [[MKMProfile alloc] initWithDictionary:dict];;
}

@end
```

### Samples
* Register User

```
// generate asymmetric keys
MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
MKMPublicKey *PK = SK.publicKey;

// register user
MKMUser *moky = [MKMUser registerWithName:@"moky" privateKey:SK publicKey:PK];
NSLog(@"my new ID: %@", moky.ID);

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. The private key of the registered user will save into the Keychain automatically.
2. The meta & history of this user must be saved by the entity delegate after registered.

* Load User

```
MKMBarrack *barrack = [MKMBarrack sharedInstance];
DIMClient  *client  = [DIMClient sharedInstance];

// 1. initialize your delegate first
_facebook = [[Facebook alloc] init];
barrack.userDelegate      = _facebook;
barrack.contactDelegate.  = _facebook;
barrack.entityDataSource  = _facebook;
barrack.profileDataSource = _facebook;

// 2. load user from barrack
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi";  // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
MKMUser *moky = [barrack userWithID:ID];

// 3. set current user for the DIM client
client.currentUser = moky;
```
1. Your delegate must load the user data from local storage to create user,
2. After that it should try to query the newest history & profile from the network.

* Load Contact

```
MKMBarrack *barrack = [MKMBarrack sharedInstance];

// 1. get contacts (IDs) from local storage
MKMID *ID1 = [[MKMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
MKMID *ID2 = [[MKMID alloc] initWithString:MKM_MONKEY_KING_ID];

// 2. create contacts from barrack
MKMContact *hulk = [barrack contactWithID:ID1];
MKMContact *moki = [barrack contactWithID:ID2];

// 3. add contacts (IDs) to the user
[moky addContact:hulk.ID];
[moky addContact:moki.ID];
```
1. Your delegate must load the account data from local storage (or query from network) for creating contacts.
2. You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Implements a Station instance (.h/.m) for network transferring

```
#import "DIMC.h"

@interface Station : DIMStation <DIMStationDelegate>

@end
```
```
#import "Station.h"

@implementation Station

#pragma mark DIMTransceiverDelegate

// send out a data package onto network
- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(DIMTransceiverCompletionHandler _Nullable)handler {
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
    
    // 2. process system command
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *cmd = content.command;
        
        // TODO: parse & execute the system command
        
        return;
    }
    
    // 3. call Amanuensis to save the instant message
    [[DIMAmanuensis sharedInstance] recvMessage:iMsg];
}

@end
```
1. You should maintain a long TCP connection to the station.
2. If connection lost, you should try ASAP to reconnect (or send data via HTTP connection).

* Implements the conversation data source & delegate (.h/.m)

```
#import "DIMC.h"

@interface MessageProcessor : NSObject <DIMConversationDataSource, DIMConversationDelegate>

@end
```
```
#import "MessageProcessor.h"

@implementation MessageProcessor

#pragma mark DIMConversationDataSource

// get message count in the conversation
- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatBox {
    MKMID *ID = chatBox.ID;
    
    // TODO:
    
    return 0;
}

// get message at index of the conversation
- (DIMInstantMessage *)conversation:(const DIMConversation *)chatBox messageAtIndex:(NSInteger)index {
    MKMID *ID = chatBox.ID;
    
    // TODO:
    
    return nil;
}

#pragma mark DIMConversationDelegate

// Conversation factory
- (DIMConversation *)conversationWithID:(const MKMID *)ID {
    MKMEntity *entity = nil;
    if (MKMNetwork_IsPerson(ID.type)) {
        entity = MKMContactWithID(ID);
    } else if (MKMNetwork_IsGroup(ID.type)) {
        entity = MKMGroupWithID(ID);
    }
    NSAssert(entity, @"ID error");
    if (entity) {
        // create new conversation with entity (Account/Group)
        return [[DIMConversation alloc] initWithEntity:entity];
    }
    return nil;
}

// save the new message to local storage
- (BOOL)conversation:(const DIMConversation *)chatBox insertMessage:(const DIMInstantMessage *)iMsg {
    MKMID *ID = chatBox.ID;
    
    // TODO:
    
    return YES;
}

@end
```
1. Your message processor should implement saving new message and loading messages from local store.

### Samples
* Send message

```
DIMClient *client = [DIMClient sharedInstance];
DIMTransceiver *trans = [DIMTransceiver sharedInstance];

// 1. connect to a Station
Station *server = [[Station alloc] initWithHost:@"127.0.0.1" port:9527];
client.currentStation = server;
trans.delegate        = server;

// 2. create message content
NSString *text = @"Hey boy!"
DIMMessageContent *content = [[DIMMessageContent alloc] initWithText:text];
MKMID *sender = client.currentUser.ID;
MKMID *receiver = hulk.ID;

// 3. call transceiver to send out message content
[trans sendMessageContent:content 
                     from:sender
                       to:receiver
                 callback:^(const DIMCertifiedMessage *cMsg, const NSError * _Nullable error) {
                     if (error) {
                         // TODO: 3.1 process error callback
                     } else {
                         // TODO: 3.2 process success callback
                     }
                 }];
```

* Receive message

```
// create your message processor
_myMessageProcessor = [[MessageProcessor alloc] init];

// set to the conversation manager
DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
clerk.dataSource = _myMessageProcessor;
clerk.delegate   = _myMessageProcessor;

// 1. when your network connection received a message data from station,
//    you should decompress(if need) and call the Transceiver to verify
//    and decrypt it to an instant message;
// 2. after that, you could try to recognize the message type, if it is
//    a system command, you could run your scripts for it, otherwise
//    call the Amanuensis to handle the message;
// 3. the Amanuensis will insert it into the chat box (Conversation)
//    that the message belongs to;
// 4. finally, the chat box will call your message processor to save it,
//    the Amanuensis will set your message processor into each chat box
//    automatically, unless you have already specify them.
```

---
Written by [Albert Moky](http://moky.github.com/) @2018
