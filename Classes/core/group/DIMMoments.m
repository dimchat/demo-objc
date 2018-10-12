//
//  DIMMoments.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMoments.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;

@end

@implementation DIMMoments

+ (instancetype)momentsWithID:(const MKMID *)ID {
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMMeta *meta = [em metaWithID:ID];
    NSAssert(meta, @"no meta found for ID: %@", ID);
    
    switch (ID.address.network) {
        case MKMNetwork_Main:
            // transform Account ID into Moments ID
            ID = [meta buildIDWithNetworkID:MKMNetwork_Moments];
            return [[DIMMoments alloc] initWithID:ID meta:meta];;
            break;
            
        case MKMNetwork_Moments:
            return [[DIMMoments alloc] initWithID:ID meta:meta];;
            break;
            
        default:
            break;
    }
    
    NSAssert(false, @"address error");
    return nil;
}

@end

#pragma mark - Connection between Account & Moments

@implementation DIMMoments (Connection)

- (MKMID *)account {
    return [self.meta buildIDWithNetworkID:MKMNetwork_Main];
}

@end

@implementation MKMAccount (Connection)

- (MKMID *)moments {
    return [self.meta buildIDWithNetworkID:MKMNetwork_Moments];
}

@end
