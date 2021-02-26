//

// KTFileHandle.h
// KTDirectSeedingSDK_Example

// Created by KestralTorah (郭炜) on 2021/2/25
// E-mail: guowei@huami.com
// Copyright © 2021 kestraltorah@163.com. All rights reserved.

    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTFileManager : NSObject

+ (instancetype)shareInstance;


/// 同步读取文件
/// @param path 文件路径
- (NSData *)readFile:(NSString *)path;

/// 异步读取文件
/// @param path 文件路径
/// @param complete 读取结果
- (void)readFileAsync:(NSString *)path
             complete:(void (^)(NSData *data))complete;

/// 同步写入文件
/// @param path 文件路径
/// @param data 文件数据
/// @param cover 是否覆盖
/// @param seekToEnd 是否追加到文件末尾
- (void)writeFile:(NSString *)path
             data:(NSData *)data
        seekToEnd:(BOOL)seekToEnd;

/// 异步写入文件
/// @param path 文件路径
/// @param data 文件数据
/// @param seekToEnd 是否追加到文件末尾 NO：覆盖 YES：追加
- (void)writeFileAsync:(NSString *)path
                  data:(NSData *)data
             seekToEnd:(BOOL)seekToEnd;

/// 移除文件
/// @param path 文件路径
- (BOOL)removeFile:(NSString *)path;


/// 文件是否存在
/// @param path 文件路径
- (BOOL)isFileExit:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
