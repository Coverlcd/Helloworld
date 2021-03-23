//
//  ViewController.m
//  Demo01
//
//  Created by Cover D on 2021/3/8.
//

#import "ViewController.h"
#import <ARKit/ARKit.h>

@interface ViewController () <ARSCNViewDelegate>
@property (nonatomic,strong) ARSCNView*scnView;
@property (nonatomic,strong) ARConfiguration*sessionConfig;
@property (nonatomic,strong) UIView*maskView;
@property (nonatomic,strong) UILabel*tipLabel;
@property (nonatomic,strong) UILabel*infoLabel;
@end

@implementation ViewController

- (ARSCNView*)SCNView
{
    if (nil == _scnView)
    {
        _scnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    }
    return _scnView;
}

- (ARConfiguration*)sessionConfig
{
    if (nil == _sessionConfig)
    {
        if ([ARWorldTrackingConfiguration isSupported])
        {
            ARWorldTrackingConfiguration *worldConfig = [ARWorldTrackingConfiguration new];
            worldConfig.planeDetection = ARPlaneDetectionHorizontal;
            worldConfig.lightEstimationEnabled = YES;
            _sessionConfig = worldConfig;
        }else
        {
            AROrientationTrackingConfiguration *orientationConfig = [AROrientationTrackingConfiguration new];
            _sessionConfig = orientationConfig;
            self.tipLabel.text = @"当前设备不支持6DOF跟踪";
        }
    }
    return _sessionConfig;
}
//一直出现maskView
-(UIView *)maskView
{
    if (nil == _maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor redColor];
        _maskView.alpha = 0.6;
    }
    return _maskView;
}

-(UILabel *)infoLabel
{
    if (nil == _infoLabel)
    {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame),CGRectGetWidth(self.tipLabel.frame),150);
        _infoLabel.numberOfLines = 0;
        _infoLabel.textColor = [UIColor blackColor];
    }
    return _infoLabel;
}

-(UILabel *)tipLabel
{
    if (nil == _tipLabel)
    {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.frame = CGRectMake(0, 30, CGRectGetWidth(self.scnView.frame), 50);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor blackColor];
    }
    return _tipLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scnView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.infoLabel];
    self.scnView.delegate = self;
    self.scnView.showsStatistics = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scnView.session runWithConfiguration:self.sessionConfig];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scnView.session pause];
}

-(void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera
{
    switch (camera.trackingState)
    {
        case ARTrackingStateNotAvailable:
        {
            self.tipLabel.text = @"跟踪不可用";
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.7;
            }];
        }
            break;
        case ARTrackingStateLimited:
        {
            NSString *title = @"有限的跟踪，原因为：";
            NSString *desc;
            switch (camera.trackingStateReason)
            {
                case ARTrackingStateReasonNone:
                    desc = @"不受约束";
                    break;
                case ARTrackingStateReasonInitializing:
                    desc = @"正在初始化，请稍等";
                    break;
                case ARTrackingStateReasonExcessiveMotion:
                    desc = @"设备移动过快，请注意";
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                    desc = @"提取不到足够的特征点，请移动设备";
                    break;
                default:
                    break;
            }
            self.tipLabel.text = [NSString stringWithFormat:@"%@%@",title,desc];
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.6;
            }];
        }
            break;
        case ARTrackingStateNormal:
        {
            self.tipLabel.text = @"跟踪正常";
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha  = 0.0;
            }];
        }
            break;
        default:
            break;
    }
}

-(void)sessionWasInterrupted:(ARSession *)session
{
    self.tipLabel.text = @"会话中断";
}

-(void)sessionInterruptionEnded:(ARSession *)session
{
    self.tipLabel.text = @"会话中断结束，已重置会话";
    [self.scnView.session runWithConfiguration:self.sessionConfig options:ARSessionRunOptionResetTracking];
}

-(void) session:(ARSession *)session didFailWithError:(nonnull NSError *)error
{
    switch (error.code)
    {
        case ARErrorCodeUnsupportedConfiguration:
            self.tipLabel.text = @"当前设备不支持";
            break;
        case ARErrorCodeSensorUnavailable:
            self.tipLabel.text = @"传感器不可用，请检查传感器";
            break;
        case ARErrorCodeSensorFailed:
            self.tipLabel.text = @"传感器出错，请检查传感器";
            break;
        case ARErrorCodeCameraUnauthorized:
            self.tipLabel.text = @"相机不可用，请检查相机";
            break;
        case ARErrorCodeWorldTrackingFailed:
            self.tipLabel.text = @"跟踪出错，请重制";
            break;
        default:
            break;
    }
}

-(void) touchesbegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    matrix_float4x4 transform = self.scnView.session.currentFrame.camera.transform;
    NSMutableString *infoStr = [NSMutableString new];
    
    for (int i=0; i<4; i++)
    {
        [infoStr appendString:[NSString stringWithFormat:@"%f,%f,%f,%f",transform.columns[i].x,transform.columns[i].y,transform.columns[i].z,transform.columns[i].w]];
    }
    self.infoLabel.text = infoStr;
}

@end

