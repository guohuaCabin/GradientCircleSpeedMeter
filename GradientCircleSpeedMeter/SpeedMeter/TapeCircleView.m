//
//  TapeCircleView.m
//  GFFStock
//
//  Created by qinguohua on 2019/8/10.
//  Copyright © 2019 guohua. All rights reserved.
//

#import "TapeCircleView.h"
#import "UIColor+GH.h"
@interface TapeCircleView ()
//箭头
@property (nonatomic,strong) UIImageView *arrowsImgView;
//圆形中的label
@property(strong,nonatomic)UILabel *valueLabel;

// CADisplayLink 定时器
@property(strong,nonatomic)CADisplayLink *displayLink;

//开始的角度
@property(assign,nonatomic)CGFloat startAngle;
@property(assign,nonatomic)CGFloat startA;
@property(assign,nonatomic)CGFloat endAngle;

//value值
@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) CGFloat addValueNumber;
//半径
@property (nonatomic,assign) CGFloat radius;
//圆中心x和中心y
@property (nonatomic,assign) CGFloat arcCenterX;
@property (nonatomic,assign) CGFloat arcCenterY;
//虚线圆的线宽和间隔
@property (nonatomic,assign) CGFloat dashedLineW;
@property (nonatomic,assign) CGFloat dashedLineSpace;

//当前角度
@property (nonatomic,assign) CGFloat curAngle;

@end

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

static const NSInteger LINEWIDTH = 6;

@implementation TapeCircleView



- (instancetype)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame: frame];
    if (self) {
        [self initDatas];
        //先画一个底层圆
        [self drawBottomCircle];
        [self createArrowsImgView];
        [self createValueLabel];
        
    }
    return self;
}

-(void)initDatas
{
    _addValueNumber = 0.f;
    _startAngle = M_PI_2;
    _curAngle = 0;
    _radius = (self.frame.size.width-LINEWIDTH*2)*0.5;
    _arcCenterX = self.frame.size.width * 0.5;
    _arcCenterY = self.frame.size.height * 0.5;
    
    CGFloat circumference = _radius*2*M_PI;
    CGFloat part = 20;
    //将圆周长分成20份，dashedLineW取每份的0.8，dashedLineSpace取每份的0.2
    _dashedLineW        = circumference/part*0.80;
    _dashedLineSpace    = circumference/part*0.20;
    
    _startA = (_dashedLineSpace +_dashedLineSpace ) / circumference *3*0.5;
    
    _startAngle = M_PI+_startA;
    _endAngle = -_startA;
    
}

#pragma mark - **************** draw circle
//画底部虚线圆
- (void)drawBottomCircle
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
    //用progressLayer来截取渐变层 遮罩
    [gradientLayer setMask:shapeLayer];
    [self.layer addSublayer:gradientLayer];
 
}

-(void)createValueLabel
{
    if (_valueLabel) {
        return;
    }
    
    CGFloat valueLabX = _arcCenterX - _radius + LINEWIDTH;
    CGFloat valueLabW = 2*_radius - LINEWIDTH*2;
    CGFloat valueLabH = 16.f;
    CGFloat valueLabY = LINEWIDTH + _radius  - valueLabH-valueLabH;
    _valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(valueLabX, valueLabY, valueLabW, valueLabH)];
    _valueLabel.text = @"0.00";
    _valueLabel.textColor = gh_colorHexValue(0xD0021D);
    _valueLabel.font = [UIFont boldSystemFontOfSize:16.f];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_valueLabel];
    
}

//创建timer
-(void)addDislayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    _displayLink.frameInterval = 2.5f;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)createArrowsImgView
{
    _arrowsImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13, 13)];
    _arrowsImgView.image = [UIImage imageNamed:@"arrows_icon"];
    [self addSubview:_arrowsImgView];
    
}

#pragma mark - **************** update
-(void)configData:(id)ViewModel
{
    _value = 0.75;
    //将进度转换成角度
    [self addDislayLink];
}



#pragma mark - **************** action
-(void)displayLinkAction
{
    _addValueNumber += 0.01;
    CGRect frame = [self getEndPointFrameWithProgress:_addValueNumber];
    _arrowsImgView.frame = frame;
    
    if (_addValueNumber >= _value) {
        CGFloat angle = ( _addValueNumber * M_PI - M_PI_2 );
        _addValueNumber = _value;
        _arrowsImgView.transform = CGAffineTransformMakeRotation(angle);
        [_displayLink invalidate];//DEGREES_TO_RADIANS(angle / M_PI *360.f)
    }
    
    _valueLabel.text = [NSString stringWithFormat:@"%.2f",_addValueNumber*100];
}

/*
 象限
                |
                |
     第一区域     |   第二区域
                |
 --------------------------------
                |
     第三区域     |   第四区域
                |
                |
 
 */

//更新小点的位置
-(CGRect)getEndPointFrameWithProgress:(CGFloat)progress
{
    //将进度转换成弧度
    _curAngle = _startA+(M_PI-2*_startA)*progress;
    //用户区分在第几象限内
    NSInteger index = (_curAngle)/M_PI_2;
    //用于计算正弦/余弦的角度
    CGFloat needAngle = _curAngle - index*M_PI_2;
    //用于保存_dotView的frame
    CGFloat x = 0,y = 0;
    switch (index) {
        case 0:
            NSLog(@"第一区域");
            x = _radius - cosf(needAngle)*_radius;
            y = _radius - sinf(needAngle)*_radius;
            
            break;
        case 1:
            NSLog(@"第二区域");
            x = _radius + sinf(needAngle)*_radius;
            y = _radius - cosf(needAngle)*_radius;
            break;
        case 2:
            NSLog(@"第三区域");
            x = _radius + cosf(needAngle)*_radius;
            y = _radius + sinf(needAngle)*_radius;
            
            break;
        case 3:
            NSLog(@"第四区域");
            x = _radius - sinf(needAngle)*_radius;
            y = _radius + cosf(needAngle)*_radius;
            break;
            
        default:
            break;
    }
    //为了让圆圈的中心和圆环的中心重合
    CGFloat space = 4.f;
    x -= (_arrowsImgView.bounds.size.width- space - LINEWIDTH)*0.5;
    y -= (_arrowsImgView.bounds.size.width- space - LINEWIDTH)*0.5;
    
    //更新圆环的frame
    CGRect rect = _arrowsImgView.frame;
    rect.origin.x = x;
    rect.origin.y = y;
    rect.size.width = 13.f;
    rect.size.height = 13.f;
    return  rect;
}

@end
