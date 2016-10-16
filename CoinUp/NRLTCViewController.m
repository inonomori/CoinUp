//
//  NRLTCViewController.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-12-4.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRLTCViewController.h"
#import "NRCoinUpBoard.h"
#import "ToolBox.h"
#import <AFNetworking.h>

#define UNAVAILABLE 0

@interface NRLTCViewController ()

@property (nonatomic, strong) NSTimer *UIUpdateTimer;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_OKCOIN;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_FXBTC;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BTCE;
@property (weak, nonatomic) IBOutlet UIView *cover_OKCOIN;
@property (weak, nonatomic) IBOutlet UIView *cover_FXBTC;
@property (weak, nonatomic) IBOutlet UIView *cover_BTCE;

@end

@implementation NRLTCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateLastPriceForAllPlatform:nil];
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                          target:self
                                                        selector:@selector(updateLastPriceForAllPlatform:)
                                                        userInfo:nil
                                                         repeats:YES];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchButtonTouched:(UIButton *)sender
{
    [self.delegate switchToViewControllerWithIdentifier:@"BTCViewController" Animation:UIViewAnimationOptionTransitionFlipFromRight AdditionalInitBlock:nil];
}

- (void)updateLastPriceForAllPlatform:(id)userInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"http://115.29.191.191:4322/all" parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *resultDic = (NSDictionary*)responseObject;
         double fxbtcPrice = [resultDic[@"fxbtc"] doubleValue];
         double okcoinPrice = [resultDic[@"okcoin"] doubleValue];
         double btcePrice = [resultDic[@"btc-e"] doubleValue];
         
         [self setPriceLabelForPlatform:OKCOIN withPrice:okcoinPrice];
         [self setPriceLabelForPlatform:FXBTC withPrice:fxbtcPrice];
         [self setPriceLabelForPlatform:BTCE withPrice:btcePrice];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self setPriceLabelForPlatform:OKCOIN withPrice:UNAVAILABLE];
         [self setPriceLabelForPlatform:FXBTC withPrice:UNAVAILABLE];
         [self setPriceLabelForPlatform:BTCE withPrice:UNAVAILABLE];
         NSLog(@"Error: %@", error);
     }];
}

- (void)setPriceLabelForPlatform:(COINPLATFORMTYPE)type withPrice:(double)price
{
    NSString *prefix = @"¥"; //can be extend
    if (type == BTCE)
        prefix = @"$";
    NSString *valueName = [NSString stringWithFormat:@"LastLabel_%@",[ToolBox getPlatformNameByPlatformType:type]];
    if (price - 0 < 0.0000001)
        ((UILabel*)[self valueForKey:valueName]).text = @"N/A";
    else
        ((UILabel*)[self valueForKey:valueName]).text = [NSString stringWithFormat:@"%@%.2f",prefix,price];
}

@end
