//

// KTFileHandle.m
// KTDirectSeedingSDK_Example

// Created by KestralTorah (郭炜) on 2021/2/25
// E-mail: guowei@huami.com
// Copyright © 2021 kestraltorah@163.com. All rights reserved.

    

#import "KTFileManager.h"

//线程队列名称
static char *queueName = "fileManagerQueue";

@interface KTFileManager () {
    //读写队列
    dispatch_queue_t _queue;
}

@end


@implementation KTFileManager

+ (instancetype)shareInstance {
    static id instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init {
    if(self = [super init]) {
        _queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSData *)readFile:(NSString *)path {
    __block NSData *data;
    dispatch_sync(_queue, ^{
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            data = [[NSFileManager defaultManager] contentsAtPath:path];
        }
    });
    return data;
}

- (void)readFileAsync:(NSString *)path complete:(void (^)(NSData *data))complete {
    dispatch_async(_queue, ^{
        NSData *data = nil;

        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            data = [[NSFileManager defaultManager] contentsAtPath:path];
        }

        if (complete) {
            complete(data);
        }
    });
}

- (void)writeFile:(NSString *)path
             data:(NSData *)data
        seekToEnd:(BOOL)seekToEnd {
    dispatch_barrier_sync(_queue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 如果文件不存在或者不追加 创建文件
        if (![fileManager fileExistsAtPath:path] || !seekToEnd) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            return;
        }
        // 如果追加到文件末尾
        if (seekToEnd) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        }
    });
}

- (void)writeFileAsync:(NSString *)path
                  data:(NSData *)data
             seekToEnd:(BOOL)seekToEnd {
    dispatch_barrier_async(_queue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 如果文件不存在或者不追加 创建文件
        if (![fileManager fileExistsAtPath:path] || !seekToEnd) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            return;
        }
        // 如果追加到文件末尾
        if (seekToEnd) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        }
    });
}

- (BOOL)removeFile:(NSString *)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (BOOL)isFileExit:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
@end
