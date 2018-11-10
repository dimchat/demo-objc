# Decentralized Instant Messaging Client (Objective-C)

## User & Contacts:

* Implements your entity delegate (.h/.m)

```
#import "DIMC.h"

@interface AccountDelegate : NSObject <MKMUserDelegate, MKMContactDelegate, MKMEntityDataSource, MKMProfileDataSource>

+ (instancetype)sharedInstance;

@end
```
```
#import "NSObject+Singleton.h"

#import "AccountDelegate.h"

@implementation AccountDelegate

SingletonImplementations(AccountDelegate, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        [MKMBarrack sharedInstance].userDelegate = self;
        [MKMBarrack sharedInstance].contactDelegate = self;
        
        [MKMBarrack sharedInstance].entityDataSource = self;
        [MKMBarrack sharedInstance].profileDataSource = self;
    }
    return self;
}

#pragma mark - MKMUserDelegate

- (MKMUser *)userWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMUser alloc] initWithID:ID publicKey:PK];
}

#pragma mark MKMContactDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMContact alloc] initWithID:ID publicKey:PK];
}

#pragma mark - MKMEntityDataSource

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    // TODO: load meta from local storage or network
    NSDictionary *dict;
    // ...
    return [[MKMMeta alloc] initWithDictionary:dict];;
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    // TODO: load profile from local storage or network
    NSDictionary *dict;
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
// 1. initialize your delegate first
[AccountDelegate sharedInstance];

// 2. load user from barrack
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi";  // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
MKMUser *moky = [[MKMBarrack sharedInstance] userWithID:ID]; // from factory

// 3. set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. Your delegate must load the user data from local storage to create user,
2. After that it should try to query the newest history & profile from the network.

* Load Contact

```
// 1. initialize your delegate first
[AccountDelegate sharedInstance];

// 2. get contacts from barrack
MKMID *ID1 = [[MKMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
MKMID *ID2 = [[MKMID alloc] initWithString:MKM_MONKEY_KING_ID];
MKMContact *hulk = [[MKMBarrack sharedInstance] contactWithID:ID1];
MKMContact *moki = [[MKMBarrack sharedInstance] contactWithID:ID2];

// 3. add contacts to the user
[moky addContact:hulk.ID];
[moky addContact:moki.ID];
```
1. Your delegate must load the contact data (or query from network) when need.
2. You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Implements a Station instance for network transferring

```
#import "DIMC.h"

@interface Station : DIMStation <DIMStationDelegate>

@end
```
```
#import "Station.h"

@implementation Station

- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(DIMTransceiverCompletionHandler _Nullable)handler {
    // TODO: send the data package onto the network,
    //       after that, call the completion handler with error message
    
    NSError *error;
    !handler ?: handler(error);
    
    return NO;
}

#pragma mark DIMStationDelegate

- (void)station:(const DIMStation *)station didReceiveData:(const NSData *)data {
    // 1. call Transceiver to get instant message from received data
    DIMInstantMessage *iMsg;
    iMsg = [[DIMTransceiver sharedInstance] messageFromReceivedPackage:data];
    
    // 2. process system command
    DIMMessageContent *content;
    content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        // TODO: execute the system command
        
        return;
    }
    
    // 3. call Amanuensis to save the instant message
    [[DIMAmanuensis sharedInstance] recvMessage:iMsg];
}

@end
```
1. You should maintain a long TCP connection to the station.
2. If connection lost, you should try ASAP to reconnect (or send data via HTTP connection).

* Implements the conversation data source & delegate

```
#import "DIMC.h"

@interface MessageProcessor : NSObject <DIMConversationDataSource, DIMConversationDelegate>

@end
```
```
#import "MessageProcessor.h"

@implementation MessageProcessor

#pragma mark DIMConversationDataSource

- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatBox {
    // TODO: get message count in the conversation
    return 0;
}

- (DIMInstantMessage *)conversation:(const DIMConversation *)chatBox messageAtIndex:(NSInteger)index {
    // TODO: get message at index of the conversation
    return nil;
}

#pragma mark DIMConversationDelegate

- (DIMConversation *)conversationWithID:(const MKMID *)ID {
    // TODO: Conversation factory
    return nil;
}

- (BOOL)conversation:(const DIMConversation *)chatBox insertMessage:(const DIMInstantMessage *)iMsg {
    // TODO: save the new message to local storage
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
