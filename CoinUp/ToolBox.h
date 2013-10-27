//
//  ToolBox.h
//  zjgis_mapBook
//
//  Created by Zhefu Wang on 13-4-1.
//  Copyright (c) 2013年 zjgis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TLSWAP(_t,_x,_y) do{\
_t temp;\
temp = _x;\
_x = _y;\
_y = temp;\
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

@end
