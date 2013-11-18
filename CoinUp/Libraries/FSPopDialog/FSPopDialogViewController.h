//
//  FSPopDialogViewController.h
//  PopDialog
//
//  Created by Zhefu Wang on 13-7-23.
//  Copyright (c) 2013年 Finder Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopDialogBackgroundView.h"

typedef NS_ENUM(NSInteger, FSPopDialogStyle){
    FSPopDialogStylePop,
    FSPopDialogStyleFromBottom,
    FSPopDialogStyleFromTop,
    FSPopDialogStyleFromLeft,
    FSPopDialogStyleFromRight
};




@interface FSPopDialogViewController : UIViewController

@property (nonatomic, weak) UIViewController *delegate;
@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSString *dialogViewTitle;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *okButtonTitle;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic) FSPopDialogStyle popDialogStyle;
@property (nonatomic) FSPopDialogStyle disappearDialogStyle;
@property (nonatomic) BOOL isShow;

- (void)appear;
- (void)flash;
- (void)updateContent;
- (void)disappear;

@end
