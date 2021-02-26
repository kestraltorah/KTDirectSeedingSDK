//

// KTH264Decoder.h
// KTDirectSeedingSDK

// Created by KestralTorah (郭炜) on 2021/2/25
// E-mail: guowei@huami.com
// 

/**
 H264解码 H264->YUV

 */

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KTVideoH264DecoderDelegate <NSObject>

/// H264解码数据回调
/// @param imageBuffer CVImageBufferRef
- (void)videoDecodeOutputDataCallback:(CVImageBufferRef)imageBuffer;

@end

@interface KTVideoDecoder_H264 : NSObject

/// 代理
@property (nonatomic, weak) id<KTVideoH264DecoderDelegate> delegate;

/// 解码原始H264nalu数据
- (void)decodeNaluData:(NSData *)naluData;

@end

NS_ASSUME_NONNULL_END
