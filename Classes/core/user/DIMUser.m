//
//  DIMUser.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMUser.h"

@interface DIMUser ()

@property (strong, nonatomic) const MKMKeyStore *keyStore;

@end

@implementation DIMUser

+ (instancetype)registerWithName:(const NSString *)seed
                       publicKey:(const MKMPublicKey *)PK
                      privateKey:(const MKMPrivateKey *)SK {
    DIMUser *user = [super registerWithName:seed
                                  publicKey:PK privateKey:SK];
    user.keyStore = [[MKMKeyStore alloc] initWithPublicKey:PK
                                                privateKey:SK];
    return user;
}

+ (instancetype)registerWithName:(const NSString *)seed
                        keyStore:(const MKMKeyStore *)store {
    DIMUser *user = [super registerWithName:seed
                                  publicKey:store.publicKey
                                 privateKey:store.privateKey];
    user.keyStore = store;
    return user;
}

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)msg {
    const DIMEnvelope *env = msg.envelope;
    const MKMID *to = env.receiver;
    NSAssert([to isEqual:self.ID], @"recipient error");
    
    // 1. use the user's private key to decrypt the symmetric key
    const NSData *PW = msg.secretKey;
    NSAssert(PW, @"secret key cannot be empty");
    PW = [self decrypt:PW];
    
    // 2. use the symmetric key to decrypt the content
    MKMSymmetricKey *scKey;
    scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    const NSData *CT = [scKey decrypt:msg.content];
    
    // 3. JsON
    NSString *json = [CT UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 4. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:env];
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)msg {
    const DIMEnvelope *env = msg.envelope;
    const MKMID *from = env.sender;
    NSAssert([from isEqual:self.ID], @"sender error");
    
    const NSData *content = msg.content;
    NSAssert(content, @"content cannot be empty");
    
    // 1. use the user's private key to sign the content
    const NSData *CT = [self sign:content];
    
    // 2. create certified message
    const NSData *key = msg.secretKey;
    return [[DIMCertifiedMessage alloc] initWithContent:content
                                               envelope:env
                                              secretKey:key
                                              signature:CT];
}

#pragma mark - Decrypt/Sign functions for passphrase/signature

- (NSData *)decrypt:(const NSData *)ciphertext {
    const MKMPrivateKey *SK = [_keyStore privateKey];
    return [SK decrypt:ciphertext];
}

- (NSData *)sign:(const NSData *)plaintext {
    const MKMPrivateKey *SK = [_keyStore privateKey];
    return [SK sign:plaintext];
}

@end
