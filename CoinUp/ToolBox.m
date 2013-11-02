//
//  ToolBox.m
//  zjgis_mapBook
//
//  Created by Zhefu Wang on 13-4-1.
//  Copyright (c) 2013年 zjgis. All rights reserved.
//

#import "ToolBox.h"

@implementation ToolBox

+ (CGSize)getApplicationFrameSize
{
    CGSize size = [UIScreen mainScreen].applicationFrame.size;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        size = [UIScreen mainScreen].bounds.size;
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        TLSWAP(CGFloat, size.width, size.height);
    }
    return size;
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)opacity
{
    CGFloat red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    CGFloat green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    CGFloat blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

+ (NSString *)DestPathDocuments:(NSString *)filename
{
    return [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],filename];
}

+ (NSURL*)getKLineURLForPlatform:(COINPLATFORMTYPE)platfom ForTimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval
{
    NSInteger timeIntervalInSeconds;
    switch (timeInterval) {
        case NRCPKLINETIMEINTERVAL24H:
            timeIntervalInSeconds = 86400;
            break;
        case NRCPKLINETIMEINTERVAL1H:
        case NRCPKLINETIMEINTERVAL30M:
        case NRCPKLINETIMEINTERVAL15M:
            timeIntervalInSeconds = 900;
            break;
        default:
            break;
    }
    
    NSString *platform_URL = @"";
    switch (platfom) {
        case OKCOIN:
            platform_URL = @"okcoinBTCCNY";
            break;
            
        default:
            break;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://info.btc123.com/data/%@/%d/bars.json",platform_URL,timeIntervalInSeconds]];
}

@end
