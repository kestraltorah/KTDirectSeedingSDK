//

// KTH264Encoder.m
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/2/25
// E-mail: guowei@huami.com
// 

    

#import "KTVideoEncoder.h"

@implementation KTVideoEncoderParam

/// 配置默认编码器参数
- (instancetype)init {
    self = [super init];
    if (self) {
        self.profileLevel = KTEncoderProfileLevelBase; // H264协议等级 不同的清晰度使用不同的ProfileLevel
        self.encodeType = kCMVideoCodecType_H264; // 编码类型
        self.bitRate = 1024 * 1024; // 码率 可动态配置
        self.frameRate = 15;  // 帧率
        self.maxKeyFrameInterval = 240; // 关键帧间隔
        self.allowFrameReordering = NO; // 是否允许产生B帧
    }
    return self;
}

@end


@interface KTVideoEncoder()

/// videoToolBox编码器
@property (assign, nonatomic) VTCompressionSessionRef compressionSessionRef;

/// 判断是否进行编码操作
@property (nonatomic, assign, getter=isStartEncode) BOOL startEncode;

@end

@implementation KTVideoEncoder

/// 移除编码器相关
- (void)dealloc {
    NSLog(@"%s", __func__);
    if (NULL == _compressionSessionRef) {
        return;
    }
    VTCompressionSessionCompleteFrames(_compressionSessionRef, kCMTimeInvalid);
    VTCompressionSessionInvalidate(_compressionSessionRef);
    CFRelease(_compressionSessionRef);
    _compressionSessionRef = NULL;
}

/// 初始化编码器
/// @param param 编码参数
- (instancetype)initWithParam:(KTVideoEncoderParam *)param {
    if (self = [super init]) {
        self.videoEncodeParam = param;

        // 创建硬编码器
        OSStatus status = VTCompressionSessionCreate(NULL, (int)self.videoEncodeParam.encodeWidth, (int)self.videoEncodeParam.encodeHeight, self.videoEncodeParam.encodeType, NULL, NULL, NULL, encodeOutputDataCallback, (__bridge void *)(self), &_compressionSessionRef);
        // 编码器创建失败
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::VTCompressionSessionCreate:failed status:%d", (int)status);
            return nil;
        }
        // 编码器未初始化
        if (NULL == self.compressionSessionRef) {
            NSLog(@"KTVideoEncoder::调用顺序错误");
            return nil;
        }

        // 设置码率 平均码率
        if (![self adjustBitRate:self.videoEncodeParam.bitRate]) {
            return nil;
        }

        // ProfileLevel，h264的协议等级，不同的清晰度使用不同的ProfileLevel。
        CFStringRef profileRef = kVTProfileLevel_H264_Baseline_AutoLevel;
        switch (self.videoEncodeParam.profileLevel) {
            case KTEncoderProfileLevelBase:
                profileRef = kVTProfileLevel_H264_Baseline_3_1;
                break;
            case KTEncoderProfileLevelMain:
                profileRef = kVTProfileLevel_H264_Main_3_1;
                break;
            case KTEncoderProfileLevelHigh:
                profileRef = kVTProfileLevel_H264_High_3_1;
                break;
        }
        status = VTSessionSetProperty(_compressionSessionRef, kVTCompressionPropertyKey_ProfileLevel, profileRef);
        CFRelease(profileRef);
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_ProfileLevel failed status:%d", (int)status);
            return nil;
        }

        // 设置实时编码输出（避免延迟）
        status = VTSessionSetProperty(_compressionSessionRef, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_RealTime failed status:%d", (int)status);
            return nil;
        }

        // 配置是否产生B帧
        status = VTSessionSetProperty(_compressionSessionRef, kVTCompressionPropertyKey_AllowFrameReordering, self.videoEncodeParam.allowFrameReordering ? kCFBooleanTrue : kCFBooleanFalse);
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_AllowFrameReordering failed status:%d", (int)status);
            return nil;
        }

        // 配置I帧间隔 I帧间隔越小 画面越清晰 数据越大
        status = VTSessionSetProperty(_compressionSessionRef,
                                      kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(self.videoEncodeParam.frameRate * self.videoEncodeParam.maxKeyFrameInterval));
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_MaxKeyFrameInterval failed status:%d", (int)status);
            return nil;
        }
        status = VTSessionSetProperty(_compressionSessionRef,
                                      kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration,
                                      (__bridge CFTypeRef)@(self.videoEncodeParam.maxKeyFrameInterval));
        if (noErr != status) {
            NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration failed status:%d", (int)status);
            return nil;
        }

        // 编码器准备编码
        status = VTCompressionSessionPrepareToEncodeFrames(_compressionSessionRef);

        if (noErr != status) {
            NSLog(@"KTVideoEncoder::VTCompressionSessionPrepareToEncodeFrames failed status:%d", (int)status);
            return nil;
        }
    }
    return self;
}

/// 开始编码
- (BOOL)startVideoEncode {
    if (NULL == self.compressionSessionRef) {
        NSLog(@"KTVideoEncoder::调用顺序错误");
        self.startEncode = NO;
        return NO;
    }

    // 编码器准备编码
    OSStatus status = VTCompressionSessionPrepareToEncodeFrames(_compressionSessionRef);
    if (noErr != status) {
        NSLog(@"KTVideoEncoder::VTCompressionSessionPrepareToEncodeFrames failed status:%d", (int)status);
        self.startEncode = NO;
        return NO;
    }
    self.startEncode = YES;
    return YES;
}

/// 停止编码
- (BOOL)stopVideoEncode {
    if (NULL == _compressionSessionRef) {
        self.startEncode = NO;
        return NO;
    }

    OSStatus status = VTCompressionSessionCompleteFrames(_compressionSessionRef, kCMTimeInvalid);

    if (noErr != status) {
        NSLog(@"KTVideoEncoder::VTCompressionSessionCompleteFrames failed! status:%d", (int)status);
        self.startEncode = NO;
        return NO;
    }
    self.startEncode = NO;
    return YES;
}

/// 编码过程中调整码率
/// @param bitRate 码率
- (BOOL)adjustBitRate:(NSInteger)bitRate {
    if (bitRate <= 0) {
        NSLog(@"KTVideoEncoder::adjustBitRate failed! bitRate <= 0");
        return NO;
    }
    OSStatus status = VTSessionSetProperty(_compressionSessionRef, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(bitRate));
    if (noErr != status) {
        NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_AverageBitRate failed status:%d", (int)status);
        return NO;
    }

    // 参考webRTC 限制最大码率不超过平均码率的1.5倍
    int64_t dataLimitBytesPerSecondValue =
    bitRate * 1.5 / 8;
    CFNumberRef bytesPerSecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &dataLimitBytesPerSecondValue);
    int64_t oneSecondValue = 1;
    CFNumberRef oneSecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &oneSecondValue);
    const void* nums[2] = {bytesPerSecond, oneSecond};
    CFArrayRef dataRateLimits = CFArrayCreate(NULL, nums, 2, &kCFTypeArrayCallBacks);
    status = VTSessionSetProperty( _compressionSessionRef, kVTCompressionPropertyKey_DataRateLimits, dataRateLimits);
    if (noErr != status) {
        NSLog(@"KTVideoEncoder::kVTCompressionPropertyKey_DataRateLimits failed status:%d", (int)status);
        return NO;
    }
    return YES;
}

/**
 输入待编码数据

 @param sampleBuffer 待编码数据
 @param forceKeyFrame 是否强制I帧
 @return 结果
 */
- (BOOL)videoEncodeInputData:(CMSampleBufferRef)sampleBuffer forceKeyFrame:(BOOL)forceKeyFrame {
    if (!self.isStartEncode) {
        return NO;
    }
//    NSAssert(self.isStartEncode, @"KTVideoEncoder::startVideoEncode should be call");

    if (NULL == _compressionSessionRef) {
        return NO;
    }

    if (nil == sampleBuffer) {
        return NO;
    }

    CVImageBufferRef pixelBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    NSDictionary *frameProperties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @(forceKeyFrame)};

    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSessionRef, pixelBuffer, kCMTimeInvalid, kCMTimeInvalid, (__bridge CFDictionaryRef)frameProperties, NULL, NULL);
    if (noErr != status) {
        NSLog(@"KTVideoEncoder::VTCompressionSessionEncodeFrame failed! status:%d", (int)status);
        return NO;
    }
    return YES;
}

void encodeOutputDataCallback(void * CM_NULLABLE outputCallbackRefCon, void * CM_NULLABLE sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CM_NULLABLE CMSampleBufferRef sampleBuffer) {
    if (noErr != status || nil == sampleBuffer) {
        NSLog(@"KTVideoEncoder::encodeOutputCallback Error : %d!", (int)status);
        return;
    }

    if (nil == outputCallbackRefCon) {
        return;
    }

    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }

    if (infoFlags & kVTEncodeInfo_FrameDropped) {
        NSLog(@"KTVideoEncoder::H264 encode dropped frame.");
        return;
    }

    KTVideoEncoder*encoder = (__bridge KTVideoEncoder*)outputCallbackRefCon;
    const char header[] = "\x00\x00\x00\x01";
    size_t headerLen = (sizeof header) - 1;
    NSData *headerData = [NSData dataWithBytes:header length:headerLen];

    // 判断是否是关键帧
    bool isKeyFrame = !CFDictionaryContainsKey((CFDictionaryRef)CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0), (const void *)kCMSampleAttachmentKey_NotSync);

    if (isKeyFrame) {
        NSLog(@"KTVideoEncoder::编码了一个关键帧");
        CMFormatDescriptionRef formatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer);

        // 关键帧需要加上SPS、PPS信息
        size_t sParameterSetSize, sParameterSetCount;
        const uint8_t *sParameterSet;
        OSStatus spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDescriptionRef, 0, &sParameterSet, &sParameterSetSize, &sParameterSetCount, 0);

        size_t pParameterSetSize, pParameterSetCount;
        const uint8_t *pParameterSet;
        OSStatus ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDescriptionRef, 1, &pParameterSet, &pParameterSetSize, &pParameterSetCount, 0);

        if (noErr == spsStatus && noErr == ppsStatus) {
            NSData *sps = [NSData dataWithBytes:sParameterSet length:sParameterSetSize];
            NSData *pps = [NSData dataWithBytes:pParameterSet length:pParameterSetSize];
            NSMutableData *spsData = [NSMutableData data];
            [spsData appendData:headerData];
            [spsData appendData:sps];
            if ([encoder.delegate respondsToSelector:@selector(videoEncodeOutputDataCallback:isKeyFrame:)]) {
                [encoder.delegate videoEncodeOutputDataCallback:spsData isKeyFrame:isKeyFrame];
            }

            NSMutableData *ppsData = [NSMutableData data];
            [ppsData appendData:headerData];
            [ppsData appendData:pps];

            if ([encoder.delegate respondsToSelector:@selector(videoEncodeOutputDataCallback:isKeyFrame:)]) {
                [encoder.delegate videoEncodeOutputDataCallback:ppsData isKeyFrame:isKeyFrame];
            }
        }
    }

    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    status = CMBlockBufferGetDataPointer(blockBuffer, 0, &length, &totalLength, &dataPointer);
    if (noErr != status) {
        NSLog(@"KTVideoEncoder::CMBlockBufferGetDataPointer Error : %d!", (int)status);
        return;
    }

    size_t bufferOffset = 0;
    static const int avcHeaderLength = 4;
    while (bufferOffset < totalLength - avcHeaderLength) {
        // 读取 NAL 单元长度
        uint32_t nalUnitLength = 0;
        memcpy(&nalUnitLength, dataPointer + bufferOffset, avcHeaderLength);

        // 大端转小端
        nalUnitLength = CFSwapInt32BigToHost(nalUnitLength);

        NSData *frameData = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + avcHeaderLength) length:nalUnitLength];

        NSMutableData *outputFrameData = [NSMutableData data];
        [outputFrameData appendData:headerData];
        [outputFrameData appendData:frameData];

        bufferOffset += avcHeaderLength + nalUnitLength;

        if ([encoder.delegate respondsToSelector:@selector(videoEncodeOutputDataCallback:isKeyFrame:)]) {
            [encoder.delegate videoEncodeOutputDataCallback:outputFrameData isKeyFrame:isKeyFrame];
        }
    }
}

@end
