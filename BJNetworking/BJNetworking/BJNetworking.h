//
//  BJNetworking.h
//  BJNetworking
//
//  Created by bradleyjohnson on 2016/10/24.
//  Copyright © 2016年 bradleyjohnson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSDictionary;

@protocol BJNetworkingDelegate <NSObject>


/**
 下载任务进度
 */
-(void)BJNetworkingDownloadProgress:(float)progress;


/**
 上传任务进度
 */
-(void)BJNetworkingUploadProgress:(float)progress;


/**
 任务成功处理回调
 */
-(void)BJNetworkingDisposeSuccess:(NSURLResponse *)response data:(NSData *)data;


/**
 任务失败处理回调
 */
-(void)BJNetworkingDisposeFailure:(NSError *)error;

@end

@interface BJNetworking : NSObject


/**
 代理
 */
@property (nonatomic , weak) id<BJNetworkingDelegate> delegate;


/**
 GET 任务
 */
-(instancetype)initByGet:(NSString *)URLString;


/**
 POST 任务
 */
-(instancetype)initByPost:(NSString *)URLString parameters:(NSDictionary *)parameters;


/**
 上传任务
 */
-(instancetype)initByUpload:(NSString *)URLString headerParameters:(NSDictionary *)parameters waitUploadData:(NSData *)data;


/**
 取消任务，不可恢复
 */
-(void)cancel;


/**
 暂停任务，可恢复
 */
-(void)suspend;


/**
 恢复任务
 */
-(void)resume;


/**
 开始任务
 */
-(void)start;

@end
