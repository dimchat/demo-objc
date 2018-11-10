//
//  MKMBarrack+LocalStorage.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDictionary+Binary.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMBarrack+LocalStorage.h"

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

/**
 Get full filepath to Documents Directory
 
 @param ID - account ID
 @param filename - "meta.plist"
 @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *full_filepath(const MKMID *ID, NSString *filename) {
    assert(ID.isValid);
    // base directory: Documents/.mkm/{address}
    NSString *dir = document_directory();
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    MKMAddress *addr = ID.address;
    if (addr) {
        dir = [dir stringByAppendingPathComponent:addr];
    }
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

@implementation MKMBarrack (LocalStorage)

- (MKMMeta *)loadMetaForEntityID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    NSString *path = full_filepath(ID, @"meta.plist");
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        meta = [[MKMMeta alloc] initWithDictionary:dict];
    }
    return meta;
}

- (BOOL)saveMeta:(const MKMMeta *)meta forEntityID:(const MKMID *)ID {
    if (![meta matchID:ID]) {
        NSAssert(!meta, @"meta error: %@, ID = %@", meta, ID);
        return NO;
    }
    NSString *path = full_filepath(ID, @"meta.plist");
    NSAssert(!file_exists(path), @"no need to update meta file");
    return [meta writeToBinaryFile:path];
}

@end
