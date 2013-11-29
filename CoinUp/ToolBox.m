//
//  ToolBox.m
//  zjgis_mapBook
//
//  Created by Zhefu Wang on 13-4-1.
//  Copyright (c) 2013年 zjgis. All rights reserved.
//

#import "ToolBox.h"
#import "NRCoinUpBoard.h"

@implementation ToolBox

+ (CGSize)getApplicationFrameSize
{
    CGSize size = [UIScreen mainScreen].applicationFrame.size;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        size = [UIScreen mainScreen].bounds.size;
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        TLSWAP(size.width, size.height);
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

+ (NSURL*)getKLineURLForPlatform:(COINPLATFORMTYPE)platform ForTimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval
{
    NSInteger timeIntervalInSeconds = [self getTimeInterval:timeInterval];
    
    NSString *platform_URL = @"";
    switch (platform) {
        case OKCOIN:
            platform_URL = @"okcoinBTCCNY";
            break;
        case CHBTC:
            platform_URL = @"chbtcBTCCNY";
            break;
        case BTCCHINA:
            platform_URL = @"btccCNY";
            break;
        case MTGOX:
            platform_URL = @"USD";
            break;
        case FXBTC:
            platform_URL = @"fxbtcBTCCNY";
            break;
        case HUOBI:
            platform_URL = @"huobiBTCCNY";
            break;
        case BTCTRADE:
            platform_URL = @"btctradeBTCCNY";
            break;
        case BTC100:
            platform_URL = @"btc100BTCCNY";
            break;
        case BITSTAMP:
        {
            return nil; // we will get BITSTAMP's URL in DataPuller. Because to construct its URL, it requires SID which we can only get from NRViewController
        }
        default:
            break;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://info.btc123.com/data/%@/%d/bars.json",platform_URL,timeIntervalInSeconds]];
}

+ (NSInteger)getMoneyDivisionForPlatform:(COINPLATFORMTYPE)platform
{
    switch (platform) {
        case BITSTAMP:
            return 1;
        case FXBTC:
            return 10000;
        case MTGOX:
            return 100000;
        default:
            return 100;
    }
}

+ (NSInteger)getVolDivisionForPlatform:(COINPLATFORMTYPE)platform
{
    switch (platform) {
        case BITSTAMP:
            return 1;
        default:
        return 100000000;
    }
}

+ (NSInteger)getTimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval
{
    NSInteger timeIntervalInSeconds = 0;
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
    
    return timeIntervalInSeconds;
}

+ (NSString*)getPlatformNameByPlatformType:(COINPLATFORMTYPE)type
{
    return @[@"NOPLATFORM",@"FXBTC",@"OKCOIN",@"BTCTRADE",@"MTGOX",@"BITSTAMP",@"CHBTC",@"BTCCHINA",@"HUOBI",@"BTC100"][type];
}

+ (NSString*)getCurrentLanguage
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale displayNameForKey:NSLocaleIdentifier
                               value:[locale localeIdentifier]];
    if ([language isEqualToString:@"Chinese (China)"])
        return @"CH";
    return @"EN";
}

@end
