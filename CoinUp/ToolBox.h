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

@interface ToolBox : NSObject

+(CGSize)getApplicationFrameSize;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (NSString *)DestPathDocuments:(NSString *)filename;

@end
