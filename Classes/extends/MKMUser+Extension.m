//
//  MKMUser+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/12.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "MKMUser+Extension.h"

@implementation MKMLocalUser (Extension)

+ (nullable instancetype)userWithConfigFile:(NSString *)config {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:config];
    
    if (!dict) {
        NSLog(@"failed to load: %@", config);
        return nil;
    }
    
    DIMID *ID = DIMIDWithString([dict objectForKey:@"ID"]);
    DIMMeta *meta = MKMMetaFromDictionary([dict objectForKey:@"meta"]);
    
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    [facebook saveMeta:meta forID:ID];
    
    DIMPrivateKey *SK = MKMPrivateKeyFromDictionary([dict objectForKey:@"privateKey"]);
    [SK saveKeyWithIdentifier:ID.address];
    
    DIMLocalUser *user = DIMUserWithID(ID);
    
    // profile
    DIMProfile *profile = [dict objectForKey:@"profile"];
    if (profile) {
        // copy profile from config to local storage
        if (![profile objectForKey:@"ID"]) {
            [profile setObject:ID forKey:@"ID"];
        }
        profile = MKMProfileFromDictionary(profile);
        [[DIMFacebook sharedInstance] saveProfile:profile];
    }
    
    return user;
}

@end
