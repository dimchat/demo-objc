//
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMProfile.h"

@implementation MKMProfile

- (instancetype)init {
    if (self = [super init]) {
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setArrayValue:(NSString *)value forKey:(const NSString *)arrName {
    NSMutableArray *mArray = [_storeDictionary objectForKey:arrName];
    if (mArray) {
        NSUInteger index = [mArray indexOfObject:value];
        if (index == 0) {
            // already exists at the first place
            return;
        }
        if (![mArray isKindOfClass:[NSMutableArray class]]) {
            NSAssert([mArray isKindOfClass:[NSArray class]],
                     @"unexpected array: %@", mArray);
            // mutable it
            mArray = [mArray mutableCopy];
            [_storeDictionary setObject:mArray forKey:arrName];
        }
        if (index == NSNotFound) {
            // add to first
            [mArray insertObject:value atIndex:0];
        } else {
            // exists but not the first one
            [mArray removeObjectAtIndex:index];
            [mArray insertObject:value atIndex:0];
        }
    } else {
        // array not exists yet
        mArray = [[NSMutableArray alloc] initWithCapacity:1];
        [mArray addObject:value];
        [_storeDictionary setObject:mArray forKey:arrName];
    }
}

@end

#pragma mark - Account profile

@implementation MKMAccountProfile

- (void)setObject:(id)anObject forKey:(const NSString *)aKey {
    if ([aKey isEqualToString:@"name"]) {
        [self setName:anObject];
    } else if ([aKey isEqualToString:@"avatar"]) {
        [self setAvatar:anObject];
    } else {
        [_storeDictionary setObject:anObject forKey:aKey];
    }
}

- (id)objectForKey:(const NSString *)aKey {
    if ([aKey isEqualToString:@"name"]) {
        return self.name;
    } else if ([aKey isEqualToString:@"avatar"]) {
        return self.avatar;
    } else {
        return [_storeDictionary objectForKey:aKey];
    }
}

- (NSString *)name {
    NSArray *array = [_storeDictionary objectForKey:@"names"];
    return [array firstObject];
}

- (void)setName:(NSString *)name {
    [self setArrayValue:name forKey:@"names"];
}

- (MKMGender)gender {
    NSString *sex = [_storeDictionary objectForKey:@"gender"];
    if (!sex) {
        sex = [_storeDictionary objectForKey:@"sex"];
    }
    
    if ([sex isEqualToString:MKMMale]) {
        return MKMGender_Male;
    } else if ([sex isEqualToString:MKMFemale]) {
        return MKMGender_Female;
    } else {
        return MKMGender_Unknown;
    }
}

- (void)setGender:(MKMGender)gender {
    if (gender == MKMGender_Male) {
        [_storeDictionary setObject:MKMMale forKey:@"gender"];
    } else if (gender == MKMGender_Female) {
        [_storeDictionary setObject:MKMFemale forKey:@"gender"];
    } else {
        [_storeDictionary removeObjectForKey:@"gender"];
    }
    
    if ([_storeDictionary objectForKey:@"sex"]) {
        [_storeDictionary removeObjectForKey:@"sex"];
    }
}

- (NSString *)avatar {
    NSArray *array = [_storeDictionary objectForKey:@"photos"];
    return array.firstObject;
}

- (void)setAvatar:(NSString *)avatar {
    [self setArrayValue:avatar forKey:@"photos"];
}

- (NSString *)biography {
    NSString *bio = [_storeDictionary objectForKey:@"biography"];
    if (!bio) {
        bio = [_storeDictionary objectForKey:@"bio"];
    }
    
    return bio;
}

- (void)setBiography:(NSString *)biography {
    if (biography) {
        [_storeDictionary setObject:biography forKey:@"biography"];
    } else {
        [_storeDictionary removeObjectForKey:@"biography"];
    }
    
    if ([_storeDictionary objectForKey:@"bio"]) {
        [_storeDictionary removeObjectForKey:@"bio"];
    }
}

@end
