//
//  GZMetroUtility.h
//  GZMetro
//
//  Created by John Chen on 12-8-22.
//
//

#import <Foundation/Foundation.h>

/**
 
 FolderUtility 包含了一些对应用程序目录的操作。
 
 - 获取 document 目录路径。
 
 - 获取 caches 目录路径。
 
 - 标记某个路径上的目录不要同步到 iCloud。
 
 - 删除某个路径的目录内的所有文件。
 
 跳转测试 clearAllContentsOfDirectory:
 
 @see clearAllContentsOfDirectory:
 
 */

@interface FolderUtility : NSObject


/**
 
 返回单例对象。
 
 @return 全局唯一的 FolderUtility 类型的对象。
 
 */

+(FolderUtility * _Nonnull)sharedInstance;

/**
 
 创建文件夹
 
 @param folderPath 需要创建的文件夹路径
 
 */

-(void)createFolder:(NSString * _Nonnull)folderPath;

/**
 
 返回 document 目录路径。
 
 @return document 目录路径。
 
 */

- (NSString * _Nonnull)applicationDocumentsDirectory;


/**
 
 返回 caches 目录路径。
 
 @return caches 目录路径。
 
 */

- (NSString * _Nonnull)applicationCachesDirectory;


/**
 
 标记某个路径上的目录不要同步到 iCloud。
 
 @param directoryURL 不需要同步到 iCloud 的目录路径
 
 */

-(void)markDirectoryNotSynWithiCloud:(NSString * _Nonnull)directoryURL;


/**
 
 删除某个路径的目录内的所有文件，保留目录。
 
 @param folderPath 需要清空目录内所有文件的目录路径。
 
 */

-(void)clearAllContentsOfDirectory:(NSString * _Nonnull)folderPath;

/**
 
 通过文件大小获取用于显示的文件大小字符串
 
 @param fileSize 文件大小，单位是byte。
 @return 文件大小
 
 */
- (NSString * _Nonnull)getFileSizeString:(double)fileSize;

/**
 
 通过文件路径获取用于显示的文件大小字符串
 
 @param filePath 文件路径
 @return 文件大小
 
 */
- (double)getFileSize:(NSString * _Nonnull)filePath;

/**
 
 通过文件名获取本地缓存路径
 
 @param fileName 图片文件名，取最后一个component作为文件名
 @return 本地缓存路径
 
 */
-(NSString * _Nonnull)getCacheImagePath:(NSString * _Nonnull)fileName;

/**
 
 获取图片缓存文件夹路径
 
 @return 本地缓存文件夹路径
 
 */
-(NSString * _Nonnull)getCacheImageFolder;

/**
 
 获取帖子库路径
 
 @return 本地缓存帖子库路径
 
 */
-(NSString * _Nonnull)getStickerPackageFolder:(NSString * _Nonnull)folderName;

-(NSString *_Nonnull)getStickerPackageLibraryFolder;

-(NSString *_Nonnull)getGroupCoverImageFolder;
-(NSString *_Nonnull)getPrivateConversationCoverImageFolder;

-(NSString *_Nonnull)getCacheTabsFolder;

-(NSString *_Nonnull)getUnValidateReceiptFolder;
@end
