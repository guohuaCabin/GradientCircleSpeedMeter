# GradientCircleSpeedMeter
设计的一个渐变色的半圆速度盘。

**效果：**

![渐变色速度盘](http://res.guohuaden.com/%E6%B8%90%E5%8F%98%E6%96%B9%E7%9B%98.gif)

**绘制：**

使用UIBezierPath、CAShapelayer做半圆的绘制，CAGradientLayer设置渐变色图层。

创建渐变色代码：

```objective-c
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
```



下面是实现箭头根据数据达到相应位置的动画，有两种方案。

**实现方法一：**

使用CAKeyframeAnimation设置“指针”的动动画属性；

使用CABasicAnimation设置“指针”的翻转路径；

使用CAAnimationGroup做动画组，添加CAKeyframeAnimation 和CABasicAnimation动画。

设置动画的代码：

```objective-c
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
    
    [_arrowsImgView.layer addAnimation:ganimation forKey:@"ganimation"];
```



**方案二：**

实时计算“指针”的坐标位置并更新。在达到最终位置时，实现指针方向的旋转。

```objective-c
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

```

以上是两种实现方法。

