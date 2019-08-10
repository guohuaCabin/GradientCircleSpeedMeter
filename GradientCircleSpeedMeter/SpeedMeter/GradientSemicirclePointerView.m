//
//  GradientSemicirclePointerView.m
//  PlayBgo
//
//  Created by qinguohua on 2019/8/10.
//  Copyright © 2019 guohua. All rights reserved.
//

#import "GradientSemicirclePointerView.h"
#import "UIColor+GH.h"
@interface GradientSemicirclePointerView ()
//箭头
@property (nonatomic,strong) UIImageView *arrowsImgView;
//圆形中的label
@property(strong,nonatomic)UILabel *valueLabel;

//开始的角度
@property(assign,nonatomic)CGFloat startAngle;
//结束的角度
@property(assign,nonatomic)CGFloat endAngle;

@property (nonatomic,strong) NSTimer *timer;

//value值
@property (nonatomic,assign) CGFloat valueNum;
//半径
@property (nonatomic,assign) CGFloat radius;
//圆中心x和中心y
@property (nonatomic,assign) CGFloat arcCenterX;
@property (nonatomic,assign) CGFloat arcCenterY;
//虚线圆的线宽和间隔
@property (nonatomic,assign) CGFloat dashedLineW;
@property (nonatomic,assign) CGFloat dashedLineSpace;

@property (nonatomic,assign) CGFloat timerAddValue;
@end

static const NSInteger LINEWIDTH = 6;

static const NSInteger kTimerInterval = 1.5;

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
@implementation GradientSemicirclePointerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews
{
    [self initDatas];
    [self createBottomBezierPathLayer];
    [self createArrowsImgView];
    [self createValueLab];
}

#pragma mark - **************** update
-(void)configData:(id)ViewModel
{
    _valueNum = 75;
    //将进度转换成角度
    CGFloat rateValue = _valueNum / 100.f;
    CGFloat endA = rateValue * M_PI + M_PI;
    //光标
    [self createAnimationWithEndAngle:endA];
    
    [self numberJumpThings];
    
}

#pragma mark - Animation

- (void)createAnimationWithEndAngle:(CGFloat)endAngle { // 光标动画
    // 设置动画属性
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = kTimerInterval;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.repeatCount = 1;
    
    // 设置动画路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, _arcCenterX, _arcCenterY, _radius, _startAngle, endAngle, 0);
    pathAnimation.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_2, 0, 0, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(endAngle+M_PI_2, 0, 0, 1)];;
    animation.duration  =  kTimerInterval;
    animation.autoreverses = NO;
    animation.cumulative = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = 1;
    
    CAAnimationGroup *ganimation = [CAAnimationGroup animation];
    ganimation.animations = @[pathAnimation, animation];
    ganimation.duration = kTimerInterval;
    ganimation.removedOnCompletion = NO;
    ganimation.repeatCount = 1;
    ganimation.fillMode = kCAFillModeForwards;
    
    [_arrowsImgView.layer addAnimation:ganimation forKey:@"g"];
    
}

- (void)numberJumpThings {
    NSTimeInterval timerInterval = kTimerInterval / _valueNum;
    _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantPast]];
    
}

-(void)timerAction
{
    if (_timerAddValue >= _valueNum) {
        _timerAddValue = _valueNum;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    _timerAddValue += 1.f;
    _valueLabel.text = [NSString stringWithFormat:@"%.2f",_timerAddValue];
    
}

#pragma mark - **************** createView
-(void)initDatas
{
    _timerAddValue = 0;
    
    _radius = (self.frame.size.width - LINEWIDTH*2)*0.5;
    _arcCenterX = self.frame.size.width * 0.5;
    _arcCenterY = self.frame.size.height * 0.5;
    
    CGFloat circumference = _radius*2*M_PI;
    CGFloat part = 20;
    //将圆周长分成20份，dashedLineW取每份的0.8，dashedLineSpace取每份的0.2
    _dashedLineW        = circumference/part*0.80;
    _dashedLineSpace    = circumference/part*0.20;
    
    CGFloat startA = (_dashedLineSpace +_dashedLineSpace ) / circumference *3*0.5;
    
    _startAngle = M_PI+startA;
    _endAngle = -startA;
}
-(void)createBottomBezierPathLayer
{
    //UIBezierPath 贝塞尔曲线
    // lockwise : YES 圆弧会从弧度的起点沿着顺时针方向画弧，遇到弧度的终点停止 (lockwise是决定你的弧长怎么样的关键)
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_arcCenterX, _arcCenterY) radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    
    CAShapeLayer *shapeLayer    = [CAShapeLayer layer];
    //闭环填充的颜色
    shapeLayer.fillColor        = [UIColor clearColor].CGColor;
    //边缘线的颜色
    shapeLayer.strokeColor      = [UIColor whiteColor].CGColor;
    //线条宽度
    shapeLayer.lineWidth        = LINEWIDTH;
    //从贝塞尔曲线获取到形状
    shapeLayer.path             = bezierPath.CGPath;
    //线宽和间隔 （线宽：2 间隔：5 ）
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:_dashedLineW], [NSNumber numberWithFloat:_dashedLineSpace], nil]];
    [self.layer addSublayer:shapeLayer];
    
    //渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    UIColor *upCor = gh_colorHexValue(0xD0021D);
    UIColor *downCor = gh_colorHexValue(0x119C10);
    NSArray *colors = [NSArray arrayWithObjects:(id)[upCor CGColor],(id)[[upCor colorWithAlphaComponent:0.5] CGColor],(id)[[upCor colorWithAlphaComponent:0.2] CGColor],(id)[[downCor colorWithAlphaComponent:0.2] CGColor],(id)[[downCor colorWithAlphaComponent:0.5] CGColor],(id)[downCor CGColor], nil];
    [gradientLayer setColors:colors];
    
    gradientLayer.type = kCAGradientLayerAxial;
    [gradientLayer setStartPoint:CGPointMake(0, 1)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
    //渐变层 遮罩
    [gradientLayer setMask:shapeLayer];
    [self.layer addSublayer:gradientLayer];
}

//创建箭头
-(void)createArrowsImgView
{
    if (_arrowsImgView) {
        return;
    }
    CGFloat arrowsImgViewWH  = 13;
    CGFloat arrowsImgViewX = _arcCenterX-_radius-arrowsImgViewWH*0.5;
    _arrowsImgView = [[UIImageView alloc]initWithFrame:CGRectMake(arrowsImgViewX, _radius-arrowsImgViewWH*0.5, arrowsImgViewWH, arrowsImgViewWH)];
    UIImage *img = [UIImage imageNamed:@"arrows_icon"];
    _arrowsImgView.image = img;
    [self addSubview:_arrowsImgView];
    
    _arrowsImgView.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

-(void)createValueLab
{
    if (_valueLabel) {
        return;
    }
    
    CGFloat valueLabX = _arcCenterX - _radius + LINEWIDTH;
    CGFloat valueLabW = 2*_radius - LINEWIDTH*2;
    CGFloat valueLabH = 16;
    CGFloat valueLabY = LINEWIDTH + _radius  - valueLabH-valueLabH;
    _valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(valueLabX, valueLabY, valueLabW, valueLabH)];
    _valueLabel.text = @"0.00";
    _valueLabel.textColor = gh_colorHexValue(0xD0021D);gh_colorHexValue(0xD0021D);
    _valueLabel.font = [UIFont boldSystemFontOfSize:16.f];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_valueLabel];
    
}

@end
