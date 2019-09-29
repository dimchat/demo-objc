//
//  GZMetroUtility.m
//  GZMetro
//
//  Created by John Chen on 12-8-22.
//
//

#import "FolderUtility.h"
#import <objc/runtime.h>
#import <sys/xattr.h>
#import <UIKit/UIKit.h>

@implementation FolderUtility

+(FolderUtility *)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)createFolder:(NSString *)folderPath{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //DLog(@"Now looking for the folder path : %@", folderPath);
    
    if(![fm fileExistsAtPath:folderPath]){
        
        NSError *error;
        [fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

-(NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSString *)applicationCachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark - prevent files from being backed up to iCloud

-(void)markDirectoryNotSynWithiCloud:(NSString *)directoryURL{
    
    NSURL *url = [NSURL fileURLWithPath:directoryURL];
    [self addSkipBackupAttributeToItemAtURL:url];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    NSString* version = [[UIDevice currentDevice] systemVersion];
    if ([version isEqualToString:@"5.0.1"]) {
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
        
    }else if ([version compare:@"5.1"] != NSOrderedAscending){
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        return success;
    }
    return YES;
}

-(void)clearAllContentsOfDirectory:(NSString *)folderPath{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *contentArray = [fm contentsOfDirectoryAtPath:folderPath error:&error];
    
    for(int i=0;i<[contentArray count];i++){
        
        NSString *itemName = [contentArray objectAtIndex:i];
        NSString *fullPathName = [folderPath stringByAppendingPathComponent:itemName];
        [fm removeItemAtPath:fullPathName error:&error];
    }
}

- (double)getFileSize:(NSString *)filePath{
    
    double resultSize = 0.0;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDir;
    NSError *error;
    if([fm fileExistsAtPath:filePath isDirectory:&isDir]){
        
        if(isDir){
            
            NSError *error;
            NSArray *contentArray = [fm contentsOfDirectoryAtPath:filePath error:&error];
            
            for(int i=0;i<[contentArray count];i++){
                
                NSString *itemName = [contentArray objectAtIndex:i];
                
                NSString *fullPathName = [filePath stringByAppendingPathComponent:itemName];
                resultSize += [self getFileSize:fullPathName];
            }
        }else{
            
            NSDictionary *fattrib = [fm attributesOfItemAtPath:filePath error:&error];
    		resultSize +=[fattrib fileSize];
        }
    }
    
    return resultSize;
}

- (NSString *)getFileSizeString:(double)fileSize {
    
    NSString *result = nil;
    
    double size = fileSize/1024;
    int unit = 1;
    
    while(size > 1024){
        
        size /= 1024;
        unit ++;
    }
    
    NSString *unitString = @"byte";
    if(unit == 1){
        unitString = @"K";
    }else if(unit == 2){
        unitString = @"M";
    }else if(unit == 3){
        unitString = @"G";
    }else if(unit == 4){
        unitString = @"G";
    }
    
    result = [NSString stringWithFormat:@"%.2f %@", size, unitString];
    
    return result;
}

-(NSString *)getCacheTabsFolder{
    
    NSString *path = [self applicationCachesDirectory];
    NSString *cacheFolder = [NSString stringWithFormat:@"%@/tabs/", path];
    
    return cacheFolder;
}

- (NSString *)getUnValidateReceiptFolder{
    NSString *path = [self applicationDocumentsDirectory];
    NSString *folder = [NSString stringWithFormat:@"%@/unValidateReceipt/", path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fm fileExistsAtPath:folder isDirectory:&isDir] || !isDir){
        
        [self createFolder:folder];
    }
    
    return folder;
}

-(NSString *)getCacheImageFolder{
    
    NSString *path = [self applicationCachesDirectory];
    NSString *cacheFolder = [NSString stringWithFormat:@"%@/images/", path];
    
    return cacheFolder;
}

-(NSString *)getGroupCoverImageFolder{
    
    NSString *path = [self applicationDocumentsDirectory];
    NSString *cacheFolder = [NSString stringWithFormat:@"%@/group_cover/", path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fm fileExistsAtPath:cacheFolder isDirectory:&isDir] || !isDir){
        
        [self createFolder:cacheFolder];
        [self markDirectoryNotSynWithiCloud:cacheFolder];
    }
    
    return cacheFolder;
}

-(NSString *)getPrivateConversationCoverImageFolder{
    
    NSString *path = [self applicationDocumentsDirectory];
    NSString *cacheFolder = [NSString stringWithFormat:@"%@/private_im/", path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fm fileExistsAtPath:cacheFolder isDirectory:&isDir] || !isDir){
        
        [self createFolder:cacheFolder];
        [self markDirectoryNotSynWithiCloud:cacheFolder];
    }
    
    return cacheFolder;
}

-(NSString *)getCacheImagePath:(NSString *)fileName{
    
    if([fileName length] == 0){
        
        return [[NSBundle mainBundle] pathForResource:@"moren_pic" ofType:@"png"];
    }
    
    fileName = [fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *cacheFolder = [self getCacheImageFolder];
    NSString *localFileName = [fileName stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    localFileName = [localFileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    localFileName = [localFileName stringByReplacingOccurrencesOfString:@"^" withString:@"-"];
    localFileName = [localFileName stringByReplacingOccurrencesOfString:@"!" withString:@"-"];
    NSString *result = [NSString stringWithFormat:@"%@%@", cacheFolder, localFileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDir;
    if(![fm fileExistsAtPath:cacheFolder isDirectory:&isDir] || !isDir){
        
        [self createFolder:cacheFolder];
    }
    
    return result;
}

-(NSString *)getStickerPackageLibraryFolder{
    
    NSString *path = [self applicationDocumentsDirectory];
    NSString *cacheFolder = [NSString stringWithFormat:@"%@/stickerpackages/", path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fm fileExistsAtPath:cacheFolder isDirectory:&isDir] || !isDir){
        
        [self createFolder:cacheFolder];
        [self markDirectoryNotSynWithiCloud:cacheFolder];
    }
    
    return cacheFolder;
}

-(NSString *)getStickerPackageFolder:(NSString *)folderName{
    
    NSString *cacheFolder = [self getStickerPackageLibraryFolder];
    
    NSString *localFileName = folderName;
    NSString *result = [cacheFolder stringByAppendingPathComponent:localFileName];
    
    return result;
}

@end
