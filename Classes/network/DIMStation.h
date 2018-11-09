//
//  DIMStation.h
//  DIMC
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMServiceProvider;

@protocol DIMStationDelegate;

@interface DIMStation : DIMDictionary {
    
    NSString *_host;
    NSUInteger _port;
    
    DIMServiceProvider *_SP;
    DIMCertificateAuthority *_CA;
    
    __weak id<DIMStationDelegate> _delegate;
}

@property (readonly, strong, nonatomic) NSString *host; // Domain/IP
@property (readonly, nonatomic) NSUInteger port;        // default: 9527

@property (copy, nonatomic) DIMServiceProvider *SP;
@property (copy, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, strong, nonatomic) NSString *name; // CA.info.subject
@property (readonly, strong, nonatomic) MKMPublicKey *publicKey; // CA.info

@property (readonly, strong, nonatomic) NSURL *home; // SP.home

@property (weak, nonatomic) id<DIMStationDelegate> delegate;

+ (instancetype)stationWithStation:(id)station;

- (instancetype)initWithHost:(const NSString *)host; // port=9527
- (instancetype)initWithHost:(const NSString *)host port:(NSUInteger)port;

- (BOOL)sendData:(const NSData *)msg;

@end

#pragma mark - Delegate

@protocol DIMStationDelegate <NSObject>

- (void)station:(const DIMStation *)station didReceiveData:(const NSData *)data;

@end

NS_ASSUME_NONNULL_END
