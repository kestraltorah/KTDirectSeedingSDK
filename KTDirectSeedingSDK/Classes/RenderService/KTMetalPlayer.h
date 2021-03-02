//

// KTMetalPlayer.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/3/2
// E-mail: guowei@huami.com
// 

/**
 基于metal的渲染类 输入CVPixelBufferRef类型

 */

#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTMetalPlayer : CAMetalLayer

/** 动态调整播放器 */
- (void)adjustFrame:(CGRect)frame;

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/** 根据frame初始化播放器 */
- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
