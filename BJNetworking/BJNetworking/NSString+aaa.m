//
//  NSString+aaa.m
//  testDemo
//
//  Created by bradleyjohnson on 2016/10/20.
//  Copyright © 2016年 bradleyjohnson. All rights reserved.
//

#import "NSString+aaa.h"

@implementation NSString (aaa)

-(NSString *)chineseTranscoding
{
    NSString * string = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    return string;
}

@end
