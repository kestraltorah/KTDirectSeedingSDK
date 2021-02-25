//

// KTCaptureViewController.m
// KTDirectSeedingSDK_Example

// Created by KestralTorah (郭炜) on 2021/2/24
// E-mail: guowei@huami.com
// Copyright © 2021 kestraltorah@163.com. All rights reserved.

    

#import "KTCaptureViewController.h"
#import "KTVideoCapturer.h"

@interface KTCaptureViewController ()<KTVideoCapturerProtocol>

/// 视频采集
@property (nonatomic, strong) KTVideoCapturer *videoCapturer;

/// 视频采集参数配置
@property (nonatomic, strong) KTVideoCapturerParamers *capturerParamers;

/// 视频采集图像显示
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

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
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(10, 74, 80, 44);
    cameraButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [cameraButton setTitle:@"开始采集" forState:UIControlStateNormal];
    [cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cameraButton setBackgroundColor:[UIColor lightGrayColor]];
    [cameraButton addTarget:self action:@selector(videoCaptureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];

    UIButton *revertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    revertButton.frame = CGRectMake(10 + 80 + 10, 74, 80, 44);
    revertButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [revertButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [revertButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [revertButton setBackgroundColor:[UIColor lightGrayColor]];
    [revertButton addTarget:self action:@selector(videoRevertButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:revertButton];

    UIButton *caputureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    caputureButton.frame = CGRectMake(10 + 80 + 10 + 10 + 80, 74, 80, 44);
    caputureButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [caputureButton setTitle:@"获取截图" forState:UIControlStateNormal];
    [caputureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [caputureButton setBackgroundColor:[UIColor lightGrayColor]];
    [caputureButton addTarget:self action:@selector(imageCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:caputureButton];
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

#pragma mark -- KTVideoCapturerProtocol
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"采集到的图像数据 ：%@", sampleBuffer);
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
@end
