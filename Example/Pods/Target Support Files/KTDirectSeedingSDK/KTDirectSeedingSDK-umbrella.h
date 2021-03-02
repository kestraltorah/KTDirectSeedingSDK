#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KTAudioCapturer.h"
#import "KTMetalPlayer.h"
#import "KTVideoCapturer.h"
#import "KTVideoDecoder_H264.h"
#import "KTVideoEncoder.h"

FOUNDATION_EXPORT double KTDirectSeedingSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char KTDirectSeedingSDKVersionString[];

