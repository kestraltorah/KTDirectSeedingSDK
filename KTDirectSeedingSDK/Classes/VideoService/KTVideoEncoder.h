//

// KTH264Encoder.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/2/25
// E-mail: guowei@huami.com
// 

/**
 H264编码 YUV->H264

 */

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KTEncoderProfileLevel) {
    KTEncoderProfileLevelBase, // kVTProfileLevel_H264_Baseline_3_1
    KTEncoderProfileLevelMain, // kVTProfileLevel_H264_Main_3_1
    KTEncoderProfileLevelHigh  // kVTProfileLevel_H264_High_3_1
};

@interface KTVideoEncoderParam : NSObject

/// ProfileLevel 默认为Base h264的协议等级，不同的清晰度使用不同的ProfileLevel
@property (nonatomic, assign) KTEncoderProfileLevel profileLevel;
/// 编码内容的宽度
@property (nonatomic, assign) NSInteger encodeWidth;
/// 编码内容的高度
@property (nonatomic, assign) NSInteger encodeHeight;
/// 编码类型 默认为kCMVideoCodecType_H264
@property (nonatomic, assign) CMVideoCodecType encodeType;
/// 码率 单位kbps
@property (nonatomic, assign) NSInteger bitRate;
/// 帧率 单位为fps，缺省为15fps
@property (nonatomic, assign) NSInteger frameRate;
/// 最大I帧间隔，单位为秒，缺省为240秒一个I帧
@property (nonatomic, assign) NSInteger maxKeyFrameInterval;
/// 是否允许产生B帧 缺省为NO
@property (nonatomic, assign) BOOL allowFrameReordering;

@end

@protocol KTVideoEncoderDelegate <NSObject>

/// 编码输出数据
/// @param outputData 输出数据
/// @param isKeyFrame 是否为关键帧
- (void)videoEncodeOutputDataCallback:(NSData *)outputData isKeyFrame:(BOOL)isKeyFrame;

@end

@interface KTVideoEncoder : NSObject

/// 代理
@property (nonatomic, weak) id<KTVideoEncoderDelegate> delegate;
/// 编码参数
@property (nonatomic, strong) KTVideoEncoderParam *videoEncodeParam;

/// 初始化编码器
/// @param param 编码参数
- (instancetype)initWithParam:(KTVideoEncoderParam *)param;

/// 开始编码
/// @return 结果
- (BOOL)startVideoEncode;

/// 停止编码
/// @return 结果
- (BOOL)stopVideoEncode;

/// 输入待编码数据
/// @param sampleBuffer 待编码数据
/// @param forceKeyFrame 是否强制I帧
- (BOOL)videoEncodeInputData:(CMSampleBufferRef)sampleBuffer forceKeyFrame:(BOOL)forceKeyFrame;

/// 编码过程中调整码率
/// @param bitRate 码率
/// @return 结果
- (BOOL)adjustBitRate:(NSInteger)bitRate;

@end

NS_ASSUME_NONNULL_END
