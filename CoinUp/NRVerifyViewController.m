//
//  NRVerifyViewController.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-11-28.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRVerifyViewController.h"
#import <AFNetworking.h>

@interface NRVerifyViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) BOOL isDone;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation NRVerifyViewController

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
    self.isDone = NO;
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://info.btc123.com/waf_captcha/"]];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.imageView setImage:image];
}

- (IBAction)ButtonTouched:(UIButton *)sender
{
    if (!self.isDone)
    {
        sender.hidden = YES;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://info.btc123.com/waf_verify.htm?captcha=%@",self.textField.text]]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
    else
    {
        sender.hidden = YES;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.btc123.com/waf_verify.htm?captcha=%@",self.textField.text]]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (!self.isDone)
    {
        self.titleLabel.text = NSLocalizedString(@"pleaseEndterTheSecondVerifyCode", nil);
        self.isDone = YES;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.btc123.com/waf_captcha/"]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageView setImage:image];
        self.textField.text = @"";
        self.okButton.hidden = NO;
    }
    else
        [self.delegate dismissModalViewController];
}

@end
