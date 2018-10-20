# Decentralized Instant Messaging Client (Objective-C)

## Network connection:

* Write your connection handler

```
@interface TCPConnection : DIMConnection

// Connect to the target station
- (BOOL)connect;

// Close this connection
- (void)close;

// send data to the target station
- (BOOL)sendData:(const NSData *)jsonData;

@end
```

* Samples

```
// create your connection
TCPConnection *myConnection = [[TCPConnection alloc] init];

// set current connection for the DIM client
DIMClient  *client = [DIMClient sharedInstance];
[client setCurrentConnection:myConnection];

// connect the client to a station
DIMStation *server = [[DIMStation alloc] initWithHost:@"127.0.0.1" port:9527];
[client connect:server];

// see *Instant Messages* section for samples of 'sendData:'
```

## User & Contacts:

* Samples

```
// generate asymmetric keys
MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
MKMPublicKey *PK = SK.publicKey;

// register user
DIMUser *moky = [DIMUser registerWithName:@"moky" publicKey:PK privateKey:SK];
NSLog(@"my new ID: %@", moky.ID);

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
* The private key of the registered user will save into the Keychain automatically.
* The meta & history of this user will save in files (Documents/barrack/{address}/*.plist) by the entity delegate (DIMBarrack) after registered.

```
// load user
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi"; // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
DIMUser *moky = [[DIMBarrack sharedInstance] userForID:ID];

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
* The entity delegate (DIMBarrack) will load the user's meta & history & profile from local files first to create a user, and after that it will try to query the newest history & profile from the network.

```
// get contacts from barrack
MKMID *ID1 = [[MKMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
MKMID *ID2 = [[MKMID alloc] initWithString:MKM_MONKEY_KING_ID];
DIMContact *hulk = [[DIMBarrack sharedInstance] contactForID:ID1];
DIMContact *moki = [[DIMBarrack sharedInstance] contactForID:ID2];

// add contacts to user
[moky addContact:hulk];
[moky addContact:moki];
```
* The entity delegate (DIMBarrack) will load the contact's meta & history & profile just like the above.
* You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Write your conversation(chatroom) delegate

```
#import "DIMC.h"

@interface MessageProcessor : NSObject <DIMConversationDelegate>

// save new message to local db
- (void)conversation:(const DIMConversation *)chatroom didReceiveMessage:(const DIMInstantMessage *)iMsg;

// get messages from local db
- (NSArray *)conversation:(const DIMConversation *)chatroom messagesBefore:(const NSDate *)time maxCount:(NSUInteger)count;

@end
```

* Sample: send out message

```
// get message content
NSString *text = @"Hey boy!"
DIMMessageContent *content = [[DIMMessageContent alloc] initWithText:text];

// encrypt and sign the message content by transceiver
DIMTransceiver *trans = [[DIMTransceiver alloc] init];
DIMCertifiedMessage *cMsg = [trans encryptAndSignContent:content sender:moky.ID receiver:hulk.ID];

// send out
DIMClient *client = [DINClient sharedInstance];
DIMConnection *connection = client.currentConnection
[connection sendData:[cMsg jsonData]];
```

* Sample: receive message

```
// create your message processor
_myProcessor = [[MessageProcessor alloc] init];

// set to the conversation manager
[DIMConversationManager sharedInstance].delegate = _myProcessor;

// TODO: save the received message by your message processer
```
* Your message processor should implement saving new message and loading message partially from local store.

---
Written by [Albert Moky](http://moky.github.com/) @2018
