//
//  DIMStation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMServiceProvider;

@protocol DIMStationDelegate;

@interface DIMStation : DIMAccount <DIMTransceiverDelegate> {
    
    NSString *_host;
    NSUInteger _port;
    
    DIMServiceProvider *_SP;
    DIMCertificateAuthority *_CA;
    
    __weak id<DIMStationDelegate> _delegate;
}

@property (readonly, strong, nonatomic) NSString *host; // Domain/IP
@property (readonly, nonatomic) NSUInteger port;        // default: 9394

@property (strong, nonatomic) DIMServiceProvider *SP;
@property (strong, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, strong, nonatomic) DIMPublicKey *publicKey; // CA.info.*

@property (readonly, strong, nonatomic) NSURL *home; // SP.home

@property (weak, nonatomic) id<DIMStationDelegate> delegate;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

#pragma mark - Delegate

@protocol DIMStationDelegate <NSObject>

/**
 Received a new data package from the station

 @param station - current station
 @param data - data package
 */
- (void)station:(const DIMStation *)station didReceiveData:(const NSData *)data;

@end

NS_ASSUME_NONNULL_END
