//

// KTVideoStreamPlayLayer.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/3/2
// E-mail: guowei@huami.com
// 

/**
 基于OpenGLES的渲染类 输入CVPixelBufferRef类型

 */

#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVideoStreamPlayLayer : CAEAGLLayer

/** 根据frame初始化播放器 */
- (id)initWithFrame:(CGRect)frame;

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
