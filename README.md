# Decentralized Instant Messaging Client (Objective-C)

## Network connections:

* Your Connection

```
@interface Connection : DIMConnection

// send message data (JsON) via the connected connection
- (BOOL)sendData:(const NSData *)jsonData;

@end
```

* Your TCP Connector

```
#import "DIMC.h"

@interface TCPConnector : NSObject <DIMConnector>

// connect to a server
- (DIMConnection *)connectToStation:(const DIMStation *)srv client:(const DIMClient *)cli;

// disconnect
- (void)closeConnection:(const DIMConnection *)conn;

@end
```

* Samples

```
// create your TCP connector
_myConnector = [[TCPConnector alloc] init];

// set the connector to DIM client
DIMClient *client = [DINClient sharedInstance];
client.connector = _myConnector;

// connect the client to a station
DIMStation *server = [[DIMStation alloc] initWithHost:@"127.0.0.1" port:9527];
[client connect:server];

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
[[DINClient sharedInstance] setCurrentUser:moky];
```
```
// load user
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi"; // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
DIMUser *moky = [[DIMBarrack sharedInstance] userForID:ID];

// set current user for the DIM client
[[DINClient sharedInstance] setCurrentUser:moky];
```
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

## Instant messages:

* Your Conversation Delegate

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

// TODO: save the received message by the conversation processer
```

---
Written by [Albert Moky](http://moky.github.com/) @2018
