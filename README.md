# Decentralized Instant Messaging Client (Objective-C)

## Network connections:

* TCP Connection

```
@interface TCPConnection : DIMConnection

// send message data (JsON) via the connected connection
- (BOOL)sendData:(const NSData *)jsonData;

@end
```

* TCP Client

```
#import "DIMC.h"

@interface TCPClient : NSObject <DIMConnector>

+ (instancetype)sharedInstance;

#pragma mark - DIMConnector

// connect to a server
- (DIMConnection *)connectToStation:(const DIMStation *)srv client:(const DIMClient *)cli;

// disconnect
- (void)closeConnection:(const DIMConnection *)conn;

@end
```

* Samples

```
// create TCP connector
DIMClient *client = [DINClient sharedInstance];
client.connector = [TCPClient sharedInstance];

// connect to a station
DIMStation *server = [[DIMStation alloc] initWithHost:@"127.0.0.1" port:9527];
[client connect:server];

```

## User & Contacts:

* Samples

```
// generate RSA keys
MKMPrivateKey *SK = [[MKMPrivateKey alloc] initWithAlgorithm:ACAlgorithmRSA];
MKMPublicKey *PK = SK.publicKey;

// register user
DIMUser *moky = [DIMUser registerWithName:@"moky" publicKey:PK privateKey:SK];
// set current user for the DIM client
DIMClient *client = [DINClient sharedInstance];
[client setCurrentUser:moky];

// get contacts from barrack
MKMID *ID1 = [[MKMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
MKMID *ID2 = [[MKMID alloc] initWithString:MKM_MONKEY_KING_ID];
DIMBarrack *barrack = [DIMBarrack sharedInstance];
DIMContact *hulk = [barrack contactForID:ID1];
DIMContact *moki = [barrack contactForID:ID2];
// add contacts to user
[moky addContact:hulk];
[moky addContact:moki];
```

## Instant messages:

* Conversation Delegate

```
#import "DIMC.h"

@interface ConversationProcessor : NSObject <DIMConversationDelegate>

+ (instancetype)sharedInstance;

// save new message
- (void)conversation:(const DIMConversation *)chatroom didReceiveMessage:(const DIMInstantMessage *)iMsg;

// load messages
- (NSArray *)conversation:(const DIMConversation *)chatroom messagesBefore:(const NSDate *)time maxCount:(NSUInteger)count;

@end
```

* Samples - Send

```
// get message content
NSString *text = @"Hey boy!"
DIMMessageContent *content = [[DIMMessageContent alloc] initWithText];

// encrypt and sign the message content by transceiver
DIMTransceiver *trans = [[DIMTransceiver alloc] init];
DIMCertifiedMessage *cMsg = [trans encryptAndSignContent:content sender:moky.ID receiver:hulk.ID];

// send out
DIMClient *client = [DINClient sharedInstance];
DIMConnection *connection = client.currentConnection
[connection sendData:[cMsg jsonData]];
```

* Samples - Receive

```
DIMConversationManager *chatrooms = [DIMConversationManager sharedInstance];
chatrooms.delegate = [ConversationProcessor sharedInstance];
// TODO: save the received message by the conversation processer
```

---
Written by [Albert Moky](http://moky.github.com/) @2018
