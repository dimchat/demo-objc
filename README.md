# Decentralized Instant Messaging Client (Objective-C)

## Network connection:

* Implements a Connector to handle long links between the client & server

```
@interface TCPConnector : NSObject <DIMConnector>

// connect to a server
- (DIMConnection *)connectTo:(const DIMStation *)server;

// close a connectiion
- (void)closeConnection:(const DIMConnection *)connection;

@end
```
* Implements the Connection to send data to the connected server

```
@interface TCPConnection : DIMConnection

// send data to the target station
- (BOOL)sendData:(const NSData *)jsonData;

@end
```

* Usages

```
// create your connector
_myConnector = [[TCPConnector alloc] init];

// set current connection for the DIM client
DIMClient  *client = [DIMClient sharedInstance];
client.connector = _myConnector;

// connect the client to a station with the connector's help
DIMStation *server = [[DIMStation alloc] initWithHost:@"127.0.0.1" port:9527];
[client connectTo:server];

// see "Instant Messages" section for samples of "sendData:"
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
1. The private key of the registered user will save into the Keychain automatically.
2. The meta & history of this user will save in files (Documents/barrack/{address}/*.plist) by the entity delegate (DIMBarrack) after registered.

```
// load user
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi"; // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
DIMUser *moky = [[DIMBarrack sharedInstance] userForID:ID];

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. The entity delegate (DIMBarrack) will load the user's meta & history & profile from local files to create a user,
2. After that it will try to query the newest history & profile from the network.

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
1. The entity delegate (DIMBarrack) will load the contact's meta & history & profile just like the above.
2. You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Implements the conversation(chatroom) data source & delegate

```
#import "DIMC.h"

@interface MessageProcessor : NSObject <DIMConversationDataSource, DIMConversationDelegate>

#pragma mark DIMConversationDataSource

// get message count in the conversation
- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatroom;

// get message at index of the conversation
- (DIMInstantMessage *)conversation:(const DIMConversation *)chatroom messageAtIndex:(NSInteger)index;

#pragma mark DIMConversationDelegate

// save new message to local db
- (void)conversation:(const DIMConversation *)chatroom didReceiveMessage:(const DIMInstantMessage *)iMsg;

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

// send out the certified secure message via current connection
DIMConnection *connection = [DINClient sharedInstance].currentConnection;
NSData *data = [cMsg jsonData];
[connection sendData:data];
```

* Sample: receive message

```
// create your message processor
_myMessageProcessor = [[MessageProcessor alloc] init];

// set to the conversation manager
DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
clerk.dataSource = _myMessageProcessor;
clerk.delegate = _myMessageProcessor;

// 1. when current connection received a message data,
//    it will call the <DIMConnectionDelegate> (DIMClient as default)
//    to handle it;
// 2. the DIMClient will try to recognize the message data,
//    if it's a command, the client will handle it directly;
// 3. or if it's a certified secure message,
//    the client will insert it into the chatroom (DIMConversation)
//    that the message belongs to;
// 4. finally, the chatroom will call your message processor for saving it,
//    the clerk (DIMAmanuensis) will set your processor into each chatroom
//    automatically, unless you have already specify them.
```
1. Your message processor should implement saving new message and loading message partially from local store.

---
Written by [Albert Moky](http://moky.github.com/) @2018
