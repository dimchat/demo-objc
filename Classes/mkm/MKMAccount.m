//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMProfile.h"

#import "MKMAccount.h"

@interface MKMAccount ()

@property (nonatomic) MKMAccountStatus status;

@end

// Monkey King
static NSString *s_moki_id = @"moki@4UMagR6LXurb2qCPxH9Pea2sbMUai44itZ";
static NSString *s_moki_ct = @"qyaQSIjQfm0/v2dk7cr0Lh3VeMRFj4Bqn9AEesF5Kq6juOFoS2MZMZVaoCQnOMZF/LqHMsAtogm9kGToHu4BXqGA13N8h4vR97mo87Ezv3f+YrpIZObj3PBTs37KoPuFkQZhxLNpEPMnaosgI7hJG3T5EK7rcnkU641vXY/q65c=";
static NSString *s_moki_pk = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI2bvVLVYrb4B0raZgFP60VXYcvRmk9q56QiTmEm9HXlSPq1zyhyPQHGti5FokYJMzNcKm0bwL1q6ioJuD4EFI56Da+70XdRz1CjQPQE3yXrXXVvOsmq9LsdxTFWsVBTehdCmrapKZVVx6PKl7myh0cfXQmyveT/eqyZK1gYjvQIDAQAB";
//static NSString *s_moki_sk = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMMjZu9UtVitvgHStpmAU/rRVdhy9GaT2rnpCJOYSb0deVI+rXPKHI9Aca2LkWiRgkzM1wqbRvAvWrqKgm4PgQUjnoNr7vRd1HPUKNA9ATfJetddW86yar0ux3FMVaxUFN6F0KatqkplVXHo8qXubKHRx9dCbK95P96rJkrWBiO9AgMBAAECgYBO1UKEdYg9pxMX0XSLVtiWf3Na2jX6Ksk2Sfp5BhDkIcAdhcy09nXLOZGzNqsrv30QYcCOPGTQK5FPwx0mMYVBRAdoOLYp7NzxW/File//169O3ZFpkZ7MF0I2oQcNGTpMCUpaY6xMmxqN22INgi8SHp3wVU+2bRMLDXEc/MOmAQJBAP+Sv6JdkrY+7WGuQN5O5PjsB15lOGcr4vcfz4vAQ/uyEGYZh6IO2Eu0lW6sw2x6uRg0c6hMiFEJcO89qlH/B10CQQDDdtGrzXWVG457vA27kpduDpM6BQWTX6wYV9zRlcYYMFHwAQkE0BTvIYde2il6DKGyzokgI6zQyhgtRJ1xL6fhAkB9NvvW4/uWeLw7CHHVuVersZBmqjb5LWJU62v3L2rfbT1lmIqAVr+YT9CK2fAhPPtkpYYo5d4/vd1sCY1iAQ4tAkEAm2yPrJzjMn2G/ry57rzRzKGqUChOFrGslm7HF6CQtAs4HC+2jC0peDyg97th37rLmPLB9txnPl50ewpkZuwOAQJBAM/eJnFwF5QAcL4CYDbfBKocx82VX/pFXng50T7FODiWbbL4UnxICE0UBFInNNiWJxNEb6jL5xd0pcy9O2DOeso=";

// Immortal Hulk
static NSString *s_hulk_id = @"hulk@4cq9NGtLMZEgxYxqBiLdMw6v1RHgFmEtab";
static NSString *s_hulk_ct = @"KQtisR7OFmXtGcJHDgWXM6niUVAFsABKtZSBNswS3Z11/SWn/Sct0wNpqnOKKS27GRrtLN7ojm9oxmAXnGUbomclpDU921CeWQplm6aUK6mdC4un0o1JskL3cZmYoLUMlaScjfirCtfPxcmJMfUIDcgDA3c4yFBRZ/tvocLYq2M=";
static NSString *s_hulk_pk = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI2bvVLVYrb4B0raZgFP60VXYcvRmk9q56QiTmEm9HXlSPq1zyhyPQHGti5FokYJMzNcKm0bwL1q6ioJuD4EFI56Da+70XdRz1CjQPQE3yXrXXVvOsmq9LsdxTFWsVBTehdCmrapKZVVx6PKl7myh0cfXQmyveT/eqyZK1gYjvQIDAQAB";
//static NSString *s_hulk_sk = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMMjZu9UtVitvgHStpmAU/rRVdhy9GaT2rnpCJOYSb0deVI+rXPKHI9Aca2LkWiRgkzM1wqbRvAvWrqKgm4PgQUjnoNr7vRd1HPUKNA9ATfJetddW86yar0ux3FMVaxUFN6F0KatqkplVXHo8qXubKHRx9dCbK95P96rJkrWBiO9AgMBAAECgYBO1UKEdYg9pxMX0XSLVtiWf3Na2jX6Ksk2Sfp5BhDkIcAdhcy09nXLOZGzNqsrv30QYcCOPGTQK5FPwx0mMYVBRAdoOLYp7NzxW/File//169O3ZFpkZ7MF0I2oQcNGTpMCUpaY6xMmxqN22INgi8SHp3wVU+2bRMLDXEc/MOmAQJBAP+Sv6JdkrY+7WGuQN5O5PjsB15lOGcr4vcfz4vAQ/uyEGYZh6IO2Eu0lW6sw2x6uRg0c6hMiFEJcO89qlH/B10CQQDDdtGrzXWVG457vA27kpduDpM6BQWTX6wYV9zRlcYYMFHwAQkE0BTvIYde2il6DKGyzokgI6zQyhgtRJ1xL6fhAkB9NvvW4/uWeLw7CHHVuVersZBmqjb5LWJU62v3L2rfbT1lmIqAVr+YT9CK2fAhPPtkpYYo5d4/vd1sCY1iAQ4tAkEAm2yPrJzjMn2G/ry57rzRzKGqUChOFrGslm7HF6CQtAs4HC+2jC0peDyg97th37rLmPLB9txnPl50ewpkZuwOAQJBAM/eJnFwF5QAcL4CYDbfBKocx82VX/pFXng50T7FODiWbbL4UnxICE0UBFInNNiWJxNEb6jL5xd0pcy9O2DOeso=";

@implementation MKMAccount

- (instancetype)init {
    // TODO: prepare test account (hulk@xxx, moki@yyy) which cannot suiside
    MKMID *ID = [[MKMID alloc] initWithString:s_moki_id];
    self = [self initWithID:ID];
    return self;
}

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (!meta) {
        NSString *seed;
        MKMPublicKey *PK;
        NSData *CT;
        if ([ID isEqualToString:s_moki_id]) {
            seed = @"moki";
            NSDictionary *info = @{@"algorithm":@"RSA", @"data":s_moki_pk};
            PK = [[MKMPublicKey alloc] initWithAlgorithm:@"RSA" keyInfo:info];
            CT = [s_moki_ct base64Decode];
        } else {
            ID = [[MKMID alloc] initWithString:s_hulk_id];
            seed = @"hulk";
            NSDictionary *info = @{@"algorithm":@"RSA", @"data":s_hulk_pk};
            PK = [[MKMPublicKey alloc] initWithAlgorithm:@"RSA" keyInfo:info];
            CT = [s_hulk_ct base64Decode];
        }
        meta = [[MKMMeta alloc] initWithSeed:seed
                                   publicKey:PK
                                 fingerprint:CT
                                     version:MKMAddressDefaultVersion];
    }
    if (self = [super initWithID:ID meta:meta]) {
        _profile = [[MKMProfile alloc] init];
    }
    
    return self;
}

- (const MKMPublicKey *)publicKey {
    return _ID.publicKey;
}

@end
