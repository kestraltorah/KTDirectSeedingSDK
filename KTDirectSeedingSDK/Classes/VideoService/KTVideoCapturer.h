//

// KTVideoCapturer.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/2/24
// E-mail: guowei@huami.com
// 

/**
 摄像头采集输出类

 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KTVideoCapturerDelegate <NSObject>

/// 摄像头采集数据
/// @param sampleBuffer 摄像头采集到的CMSampleBufferRef类型、原始YUV数据
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

@interface KTVideoCapturerParamers : NSObject

/// 摄像头方向 默认为当前屏幕方向
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/// 摄像头位置，默认为前置摄像头 AVCaptureDevicePositionFront
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;

/// 视频分辨率 默认AVCaptureSessionPreset1280x720
@property (nonatomic, assign) AVCaptureSessionPreset sessionPreset;

/// 采集帧率 帧/秒 默认15/帧每秒
@property (nonatomic, assign) NSInteger frameRate;

@end

@interface KTVideoCapturer : NSObject

/// 代理
@property (nonatomic, weak) id<KTVideoCapturerDelegate> delegate;

/// 预览图层，把这个图层加在View上并且为这个图层设置frame就能播放
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

/// 视频采集参数
@property (nonatomic, strong) KTVideoCapturerParamers *captureParam;

/// 是否正在采集
@property (nonatomic, assign, readonly) BOOL isCapturing;

/// 初始化方法
/// @param param 参数
/// @param error 实例
- (instancetype)initWithCaptureParam:(KTVideoCapturerParamers *)param error:(NSError **)error;

/// 开始采集
- (NSError *)startCapture;

/// 停止采集
- (NSError *)stopCapture;

/// 抓图 block返回UIImage
- (void)imageCapture:(void(^)(UIImage *image))completion;

/// 动态调整帧率
- (NSError *)adjustFrameRate:(NSInteger)frameRate;

/// 翻转摄像头
- (NSError *)reverseCamera;

/// 采集过程中动态修改视频分辨率
- (void)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset;

@end

NS_ASSUME_NONNULL_END
