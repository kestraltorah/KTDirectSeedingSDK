//

// KTMetalPlayer.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/3/2
// E-mail: guowei@huami.com
// 

    

#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTMetalPlayer : CAMetalLayer

- (void)adjustFrame:(CGRect)frame;

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
