//
//  UIColor+GH.m
//  PlayBgo
//
//  Created by guohua on 2019/7/1.
//  Copyright © 2019 guohua. All rights reserved.
//

#import "UIColor+GH.h"

@implementation UIColor (GH)

//十六进制颜色
+(instancetype)colorFromHexString:(nullable NSString*)hexString
{
   
    return [self colorFromHexString:hexString alpha:1.0];
}
+(instancetype)colorFromHexString:(nullable NSString*)hexString alpha:(CGFloat)alpha
{
    unsigned hexValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString rangeOfString:@"#"].location != NSNotFound) {
        [scanner setScanLocation:1];
    }
    [scanner scanHexInt:&hexValue];
    return [self colorFromHexValue:hexValue alpha:1.0];
}
+(instancetype)colorFromHexValue:(NSInteger)hexValue
{
    return [self colorFromHexValue:hexValue alpha:1.0];
}
+(instancetype)colorFromHexValue:(NSInteger)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:((hexValue & 0xFF) >> 0)/255.0 alpha:alpha];
}
//rgb颜色
+(instancetype)colorFromR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue
{
    return [self colorWithRed:red green:green blue:blue alpha:1.0];
}
+(instancetype)colorFromR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha
{
    return [self colorWithRed:red green:green blue:blue alpha:alpha];
}

-(NSString *)hexString
{
    NSArray *colorArr = [self rgbaArray];
    NSInteger r = [colorArr[0] floatValue]*255;
    NSInteger g = [colorArr[1] floatValue]*255;
    NSInteger b = [colorArr[2] floatValue]*255;
    
    NSString *rStr = [NSString stringWithFormat:@"%02lx",(long)r];
    NSString *gStr = [NSString stringWithFormat:@"%02lx",(long)g];
    NSString *bStr = [NSString stringWithFormat:@"%02lx",(long)b];
    NSString *hexStr = [NSString stringWithFormat:@"#%@%@%@",rStr,gStr,bStr];
    return hexStr;
}

-(NSArray *)rgbaArray
{
    CGFloat r = 0,g = 0,b = 0, a = 0;
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return @[@(r), @(g), @(b), @(a)];
}

@end
