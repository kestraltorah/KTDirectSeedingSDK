//

// KTCaptureViewController.m
// KTDirectSeedingSDK_Example

// Created by KestralTorah (郭炜) on 2021/2/24
// E-mail: guowei@huami.com
// Copyright © 2021 kestraltorah@163.com. All rights reserved.

    

#import "KTCaptureViewController.h"
#import "KTVideoCapturer.h"  // 视频采集
#import "KTVideoEncoder.h"   // 视频编码
#import "KTFileManager.h"    // 文件操作
#import "KTVideoDecoder_H264.h" // 视频H264解码

@interface KTCaptureViewController ()<KTVideoCapturerDelegate, KTVideoEncoderDelegate, KTVideoH264DecoderDelegate>

#pragma mark -- 视频采集部分
/// 视频采集
@property (nonatomic, strong) KTVideoCapturer *videoCapturer;

/// 视频采集参数配置
@property (nonatomic, strong) KTVideoCapturerParamers *capturerParamers;

/// 视频采集图像显示
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

#pragma mark -- 视频编码部分

/// 视频编码器参数
@property (nonatomic, strong) KTVideoEncoderParam *videoEncoderParamers;

/// 视频编码器
@property (nonatomic, strong) KTVideoEncoder *videoEncoder;

/// 编码后数据写入文件路径
@property (nonatomic, copy) NSString *encoderFilePath;

#pragma mark -- 视频解码部分
/// H264视频解码器
@property (nonatomic, strong) KTVideoDecoder_H264 *videoDecoder;

@end

@implementation KTCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeViews];
}

#pragma mark -- 初始化界面
- (void)initializeViews {
    self.title = @"视频采集";
    self.view.backgroundColor = [UIColor whiteColor];

    CGFloat x = 10;
    CGFloat y = 74;
    CGFloat width = 80;
    CGFloat height = 44;
    
    [self addButtonToViewWith:@"开始采集" frame:CGRectMake(x, y, width, height) selector:@selector(videoCaptureButtonClick:)];
    [self addButtonToViewWith:@"切换摄像头" frame:CGRectMake(2 * x + width, y, width, height) selector:@selector(videoRevertButtonClick:)];
    [self addButtonToViewWith:@"获取截图" frame:CGRectMake(3 * x + 2 * width, y, width, height) selector:@selector(imageCapture)];
    [self addButtonToViewWith:@"开始编码" frame:CGRectMake(4 * x + 3 * width, y, width, height) selector:@selector(encodeVideoData:)];
}

#pragma mark -- 添加button
- (void)addButtonToViewWith:(NSString *)buttonTitle
                      frame:(CGRect)frame
                   selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
#pragma mark -- Button事件
/// 采集
- (void)videoCaptureButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        // 开始采集视频
        [button setTitle:@"停止采集" forState:UIControlStateNormal];
        [self.videoCapturer startCapture];
        [self.view.layer addSublayer:self.previewLayer];
    } else {
        // 停止采集视频
        [button setTitle:@"开始采集" forState:UIControlStateNormal];
        [self.videoCapturer stopCapture];
        [self.previewLayer removeFromSuperlayer];
    }
}

/// 切换摄像头
- (void)videoRevertButtonClick:(UIButton *)button {
    [self.videoCapturer reverseCamera];
}

/// 抓图
- (void)imageCapture {
    [self.videoCapturer imageCapture:^(UIImage * _Nonnull image) {
        NSLog(@"image : %@", image);
    }];
}

/// 视频编码
- (void)encodeVideoData:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        // 开始编码视频
        // 保留一份当前录制的H264数据
        if ([[KTFileManager shareInstance] isFileExit:self.encoderFilePath]) {
            [[KTFileManager shareInstance] removeFile:self.encoderFilePath];
        }
        [button setTitle:@"停止编码" forState:UIControlStateNormal];
        if ([self.videoEncoder startVideoEncode]) {
            NSLog(@"-------------------------开始进行H264编码操作-------------------------");
        }
    } else {
        // 停止编码视频
        [button setTitle:@"开始编码" forState:UIControlStateNormal];
        if ([self.videoEncoder stopVideoEncode]) {
            NSLog(@"-------------------------停止进行H264编码操作-------------------------");
        }
    }
}

#pragma mark -- 视频采集 KTVideoCapturerDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    [self.videoEncoder videoEncodeInputData:sampleBuffer forceKeyFrame:NO];
}

#pragma mark -- 视频编码 KTVideoEncoderDelegate
- (void)videoEncodeOutputDataCallback:(NSData *)outputData isKeyFrame:(BOOL)isKeyFrame {
    // 编码后数据写入文件 可选
    [[KTFileManager shareInstance] writeFileAsync:self.encoderFilePath data:outputData seekToEnd:YES];
    // 原始nalu数据 进行解码操作
    [self.videoDecoder decodeNaluData:outputData];
}

#pragma mark -- 视频解码 KTVideoH264DecoderDelegate
- (void)videoDecodeOutputDataCallback:(CVImageBufferRef)imageBuffer {
    NSLog(@"实时解码数据 %@", imageBuffer);
}

#pragma mark -- 懒加载
- (KTVideoCapturerParamers *)capturerParamers {
    if (!_capturerParamers) {
        _capturerParamers = [[KTVideoCapturerParamers alloc] init];
        _capturerParamers.sessionPreset = AVCaptureSessionPreset1280x720;
        _capturerParamers.frameRate = 15;
    }
    return _capturerParamers;
}

- (KTVideoCapturer *)videoCapturer {
    if (!_videoCapturer) {
        _videoCapturer = [[KTVideoCapturer alloc] initWithCaptureParam:self.capturerParamers error:nil];
        _videoCapturer.delegate = self;
    }

    return _videoCapturer;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        CGFloat layerMargin = 15;
        CGFloat layerW = (self.view.frame.size.width - 3 * layerMargin) * 0.5;
        CGFloat layerH = layerW * 16 / 9.00;
        CGFloat layerY = 120;
        _previewLayer = self.videoCapturer.videoPreviewLayer;
        _previewLayer.frame = CGRectMake(layerMargin, layerY, layerW, layerH);
    }
    return _previewLayer;
}

- (KTVideoEncoderParam *)videoEncoderParamers {
    if (!_videoEncoderParamers) {
        _videoEncoderParamers = [[KTVideoEncoderParam alloc] init];
        _videoEncoderParamers.allowFrameReordering = YES;
        _videoEncoderParamers.encodeWidth = 375.f;
        _videoEncoderParamers.encodeHeight = 667.f;
        _videoEncoderParamers.maxKeyFrameInterval = 10;
    }
    return _videoEncoderParamers;
}

- (KTVideoEncoder *)videoEncoder {
    if (!_videoEncoder) {
        _videoEncoder = [[KTVideoEncoder alloc] initWithParam:self.videoEncoderParamers];
        _videoEncoder.delegate = self;
    }
    return _videoEncoder;
}

- (NSString *)encoderFilePath {
    if (!_encoderFilePath) {
        NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *homePath = [paths objectAtIndex:0];
        _encoderFilePath = [homePath stringByAppendingPathComponent:@"encoderH264"];
    }
    return _encoderFilePath;
}

- (KTVideoDecoder_H264 *)videoDecoder {
    if (!_videoDecoder) {
        _videoDecoder = [[KTVideoDecoder_H264 alloc] init];
        _videoDecoder.delegate = self;
    }
    return _videoDecoder;
}
@end
