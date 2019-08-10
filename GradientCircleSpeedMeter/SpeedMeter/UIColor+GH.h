//
//  UIColor+GH.h
//  PlayBgo
//
//  Created by guohua on 2019/7/1.
//  Copyright © 2019 guohua. All rights reserved.
//系统颜色扩展

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: 宏定义颜色


//十六进制颜色转换

#define gh_colorHexString(hexString)             [UIColor colorFromHexString:hexString]
#define gh_colorHexString_a(hexString,a)         [UIColor colorFromHexString:hexString alpha:a]

/*
//十六进制颜色转换
#define gh_colorHexValue(hexValue)               [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:((hexValue & 0xFF) >> 0)/255.0 alpha:1.0];
#define gh_colorHexValue_a(hexValue,a)            [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:((hexValue & 0xFF) >> 0)/255.0 alpha:a];
//rgb颜色转换
#define gh_colorRGB(r,g,b)                       [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define gh_colorRGBA(r,g,b,a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
 
*/
static inline UIColor* gh_colorHexValue(int hexValue){
    return  [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:((hexValue & 0xFF) >> 0)/255.0 alpha:1.0];
}


static inline UIColor* gh_colorHexValueAndAlpha(int hexValue, CGFloat alpha){
    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:((hexValue & 0xFF) >> 0)/255.0 alpha:alpha];
}

static inline UIColor* gh_colorRGB(int r,int g,int b){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

static inline UIColor* gh_colorRGBA(int r,int g,int b,int a){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}


@interface UIColor (GH)

//十六进制颜色
+(instancetype)colorFromHexString:(nullable NSString*)hexString;
+(instancetype)colorFromHexString:(nullable NSString*)hexString alpha:(CGFloat)alpha;
+(instancetype)colorFromHexValue:(NSInteger)hexValue;
+(instancetype)colorFromHexValue:(NSInteger)hexValue alpha:(CGFloat)alpha;
//rgb颜色
+(instancetype)colorFromR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue;
+(instancetype)colorFromR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha;

//返回十六进制字符串
-(NSString *)hexString;
//返回r,g,b,a值
-(NSArray *)rgbaArray;



@end

NS_ASSUME_NONNULL_END
