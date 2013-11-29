//
//  ToolBox.h
//  zjgis_mapBook
//
//  Created by Zhefu Wang on 13-4-1.
//  Copyright (c) 2013年 zjgis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataPuller.h"

#define TLSWAP(A,B) do{\
__typeof__(A) __tmp = (A);\
A = B;\
B = __tmp;\
}while(0)

#define SCREENWIDTH [ToolBox getApplicationFrameSize].width
#define SCREENHEIGHT [ToolBox getApplicationFrameSize].height

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ToolBox : NSObject

+(CGSize)getApplicationFrameSize;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (NSString *)DestPathDocuments:(NSString *)filename;
+ (NSURL*)getKLineURLForPlatform:(COINPLATFORMTYPE)platform ForTimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval;
+ (NSInteger)getVolDivisionForPlatform:(COINPLATFORMTYPE)platform;
+ (NSInteger)getMoneyDivisionForPlatform:(COINPLATFORMTYPE)platform;
+ (NSInteger)getTimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval;
+ (NSString*)getPlatformNameByPlatformType:(COINPLATFORMTYPE)type;
+ (NSString*)getCurrentLanguage;

@end
