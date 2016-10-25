//
//  ViewController.m
//  BJNetworking
//
//  Created by bradleyjohnson on 2016/10/24.
//  Copyright © 2016年 bradleyjohnson. All rights reserved.
//

#import "ViewController.h"
#import "BJNetworking.h"

@interface ViewController ()<BJNetworkingDelegate>

@property (nonatomic , strong) UIProgressView * proView;
@property (nonatomic , strong) BJNetworking * bjnetworkingTask;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.proView.frame = CGRectMake(10, 100, self.view.bounds.size.width-20, 50);
    self.proView.trackTintColor = [UIColor grayColor];
    self.proView.progressTintColor = [UIColor orangeColor];
    [self.view addSubview:self.proView];
    
    NSArray * arr = @[@"start",@"cancle",@"suspend",@"resume"];
    
    for (NSInteger index = 0; index < 4; index++) {
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(20+index*75, 200, 70, 50)];
        button.backgroundColor = [UIColor orangeColor];
        button.tag = index+100;
        [button setTitle:arr[index] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }

// <1>.get
//    self.bjnetworkingTask = [[BJNetworking alloc] initByGet:@"http://apis.juhe.cn/mobile/get?phone=18476658843&key=653cf0de5fd4400269637780f13729f2"];
    
// <2>.post
//    self.bjnetworkingTask = [[BJNetworking alloc] initByPost:@"http://apis.juhe.cn/mobile/get" parameters:@{@"phone":@"18476658843",@"key":@"653cf0de5fd4400269637780f13729f2"}];
    
// <3>.upload
//    NSMutableDictionary * dic = [NSMutableDictionary new];
//    [dic setValue:@"303e07ae9b2325e06d79511311864413" forKey:@"X-Bmob-Application-Id"];
//    [dic setValue:@"a8f913ff4984d736a26e805bddf20146" forKey:@"X-Bmob-REST-API-Key"];
//    [dic setValue:@"image/jpeg" forKey:@"Content-Type"];
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"jpg"];
//    UIImage * image = [UIImage imageWithContentsOfFile:path];
//    NSData * data = UIImageJPEGRepresentation(image,1);
//    
//    self.bjnetworkingTask = [[BJNetworking alloc] initByUpload:@"https://api.bmob.cn/2/files/aaa.jpg" headerParameters:dic waitUploadData:data];
    
// <4.1>.download by get
//    self.bjnetworkingTask = [[BJNetworking alloc] initByGet:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.1.2.dmg"];
    
// <4.2>.download by post
    self.bjnetworkingTask = [[BJNetworking alloc] initByPost:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.1.2.dmg" parameters:nil];
    
    
    self.bjnetworkingTask.delegate = self;
}

-(void)buttonClick:(UIButton *)button
{
    switch (button.tag) {
        case 100:
        {
            [self.bjnetworkingTask start];
        }
            break;
        case 101:
        {
            [self.bjnetworkingTask cancel];
        }
            break;
        case 102:
        {
            [self.bjnetworkingTask suspend];
        }
            break;
        case 103:
        {
            [self.bjnetworkingTask resume];
        }
            break;
    }
}

#pragma mark - delegate  methods
-(void)BJNetworkingDownloadProgress:(float)progress
{
    NSLog(@"Download - progress - :%.4f",progress);
    
    __block ViewController * weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.proView.progress = progress;
    });
}

-(void)BJNetworkingDisposeSuccess:(NSURLResponse *)response data:(NSData *)data
{
    NSLog(@"response - :%@",response);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"qq.dmg"];
    
    [fm createFileAtPath:path contents:data attributes:nil];
    
//  解读 JSON 数据
//    NSLog(@"data     - :%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)BJNetworkingDisposeFailure:(NSError *)error
{
    NSLog(@"error    - :%@",error);
}

-(void)BJNetworkingUploadProgress:(float)progress
{
    NSLog(@"Upload - progress - :%.4f",progress);
    
    __block ViewController * weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.proView.progress = progress;
    });
}

@end
