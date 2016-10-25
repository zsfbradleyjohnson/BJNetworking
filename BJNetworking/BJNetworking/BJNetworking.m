//
//  BJNetworking.m
//  BJNetworking
//
//  Created by bradleyjohnson on 2016/10/24.
//  Copyright © 2016年 bradleyjohnson. All rights reserved.
//

#define ROOT_FILE_PATH [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Downloads"]

#import "BJNetworking.h"
#import "NSString+aaa.h"

@interface BJNetworking ()<NSURLSessionDelegate>

@property (nonatomic , assign) NSInteger totalLength;           //待下载数据总长度
@property (nonatomic , assign) NSInteger currentLength;         //当前下载数据总长度

@property (nonatomic , strong) NSURLSession * session;          //下载核心
@property (nonatomic , strong) NSURLSessionDataTask * dataTask; //下载任务
@property (nonatomic , strong) NSURLResponse * response;        //下载响应

@property (nonatomic , strong) NSString * fileFullName;         //下载数据临时保存绝对路径
@property (nonatomic , strong) NSFileHandle * handle;           //数据写入句柄
@property (nonatomic , strong) NSMutableDictionary * infoDic;   //下载数据信息保存字典

@end

@implementation BJNetworking

-(void)dealloc
{
    self.delegate = nil;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initializesWithFileDocuments];
    }
    return self;
}

#pragma mark - public methods

-(instancetype)initByGet:(NSString *)URLString
{
    self = [self init];
    if (self) {
        
        NSURL * url = [NSURL URLWithString:[URLString chineseTranscoding]];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        [self initializesByDownloadDataWithRequest:request];
        
    }
    return self;
}

-(instancetype)initByPost:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    self = [self init];
    if (self) {
        
        NSURL * url = [NSURL URLWithString:[URLString chineseTranscoding]];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString * body = [NSString string];
        NSDictionary * paramsDic = (NSDictionary *)parameters;
        for (NSInteger index = 0; index<paramsDic.allKeys.count; index++) {
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",paramsDic.allKeys[index],paramsDic[paramsDic.allKeys[index]]]];
        }
        
        if (body.length) {
            body = [body substringToIndex:body.length-1];
            [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [self initializesByDownloadDataWithRequest:request];
        
    }
    return self;
}

-(instancetype)initByUpload:(NSString *)URLString headerParameters:(NSDictionary *)parameters waitUploadData:(NSData *)data
{
    self = [self init];
    if (self) {
        
        NSURL * url = [NSURL URLWithString:[URLString chineseTranscoding]];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        
        for (NSInteger index = 0; index < parameters.allKeys.count; index++) {
            [request setValue:parameters[parameters.allKeys[index]] forHTTPHeaderField:parameters.allKeys[index]];
        }
        
        [self initializesByUploadDataWithRequest:request data:data];
        
    }
    return self;
}

-(void)cancel
{
    [self.dataTask cancel];
    self.dataTask = nil;
}

-(void)start
{
    [self.dataTask resume];
}

-(void)resume
{
    [self.dataTask resume];
}

-(void)suspend
{
    [self.dataTask suspend];
}

#pragma mark - private methods

/**
 创建 Download 文件夹以存放下载缓存文件
 */
-(void)initializesWithFileDocuments
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ROOT_FILE_PATH]) {
        [fileManager createDirectoryAtPath:ROOT_FILE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


/**
 完成数据下载至本地的预处理
 */
-(void)initializesByDownloadDataWithRequest:(NSMutableURLRequest *)request
{
    BOOL goOnDownload = [self shouldGoOnDownloadBy:request.URL.absoluteString];
    
    self.currentLength = 0;
    self.currentLength = [self getCurrentSize];
    NSString * range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    self.dataTask = [self.session dataTaskWithRequest:request];
    
    if (goOnDownload) {return;}
    
    self.infoDic = [NSMutableDictionary dictionary];
    [self.infoDic setValue:[self getRandom32String] forKey:@"Identifier"];
    [self.infoDic setValue:request.URL.absoluteString forKey:@"Url"];
}


/**
 完成数据上传的预处理
 */
-(void)initializesByUploadDataWithRequest:(NSURLRequest *)request data:(NSData *)data
{
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    self.dataTask = [self.session uploadTaskWithRequest:request fromData:data];
}

/**
 获取随机32位含数字、小写字母和大写字母的字符串
 */
-(NSString *)getRandom32String
{
    NSString * randomString = [NSString new];
    
    for (NSInteger index = 0; index < 32; index++) {
        
        int way = (arc4random()%30)+1;
        
        if (way<10) {
            randomString = [randomString stringByAppendingString:[NSString stringWithFormat:@"%d",arc4random()%10]];
        }else if (way>= 10 && way<20){
            randomString = [randomString stringByAppendingString:[NSString stringWithFormat:@"%c",(arc4random()%26)+65]];
        }else{
            randomString = [randomString stringByAppendingString:[NSString stringWithFormat:@"%c",(arc4random()%26)+97]];
        }
    }
    
    return randomString;
}

/**
 判断是否断点续载
 */
-(BOOL)shouldGoOnDownloadBy:(NSString *)urlstring
{
    BOOL should = NO;
    
    for (NSString * path in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_FILE_PATH error:nil]) {
        if ([path rangeOfString:@".xml"].location != NSNotFound) {
            NSDictionary * xmlDic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ROOT_FILE_PATH,path]];
            if ([[xmlDic objectForKey:@"Url"] isEqualToString:urlstring]) {
                self.infoDic = [NSMutableDictionary dictionaryWithDictionary:xmlDic];
                self.totalLength = [self.infoDic[@"TotalLength"] floatValue];
                self.fileFullName = [ROOT_FILE_PATH stringByAppendingPathComponent:[self.infoDic objectForKey:@"Identifier"]];
                should = YES;
                break;
            }
        }
    }
    
    return should;
}

/**
 断点续载情况下获取本地已下载文件大小
 */
-(NSInteger)getCurrentSize
{
    NSInteger size = 0;
    if (self.infoDic) {
        NSString *filePath = [ROOT_FILE_PATH stringByAppendingPathComponent:self.infoDic[@"Identifier"]];
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size = [dict[@"NSFileSize"] integerValue];
    }
    
    return size;
}

#pragma mark - delegate methods

-(void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow); //准许数据传输
    
    BOOL goOn = self.totalLength;                 //判断是否断点续载
    
    self.totalLength = goOn?self.totalLength:(NSInteger)(response.expectedContentLength + self.currentLength);

    self.response = response;
    
    if (!goOn) {
        // 非断点续载的情况下需要完成文件名称的设置、文件总大小的本地写入和创建下载空文件
        self.fileFullName = [ROOT_FILE_PATH stringByAppendingPathComponent:[self.infoDic objectForKey:@"Identifier"]];
        [self.infoDic setValue:@(self.totalLength) forKey:@"TotalLength"];
        [self.infoDic writeToFile:[ROOT_FILE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",[self.infoDic objectForKey:@"Identifier"]]] atomically:YES];
        
        [[NSFileManager defaultManager] createFileAtPath:self.fileFullName contents:nil attributes:nil];
    }
    
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fileFullName]; //预备写入数据到指定路径文件
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.handle writeData:data];           //写入数据
    
    //判断当前数据的下载进度
    self.currentLength += data.length;
    
    float progress = 1.0 * self.currentLength/self.totalLength;
    
    progress = (progress<.0f)?1.0:progress;
    
    if (!self.infoDic) {
        return;
    }
    
    //通过代理将数据的下载进度外露
    if ([self.delegate respondsToSelector:@selector(BJNetworkingDownloadProgress:)]) {
        [self.delegate BJNetworkingDownloadProgress:progress];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.handle closeFile];            //文件下载完成后关闭写入句柄
    
    if (error) {
        //若请求发生错误，通过代理外露
        if ([self.delegate respondsToSelector:@selector(BJNetworkingDisposeFailure:)]) {
            [self.delegate BJNetworkingDisposeFailure:error];
        }
        
        return;
    }
    
    //获取下载好的数据，通过代理方式与响应一起外露
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:self.fileFullName];
    NSData * data = [handle availableData];
    
    if ([self.delegate respondsToSelector:@selector(BJNetworkingDisposeSuccess:data:)]) {
        [self.delegate BJNetworkingDisposeSuccess:self.response data:data];
    }
    
    //待代理处理后，清除本地下载数据
    [[NSFileManager defaultManager] removeItemAtPath:self.fileFullName error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.xml",self.fileFullName] error:nil];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //通过代理将上传进度外露
    if ([self.delegate respondsToSelector:@selector(BJNetworkingUploadProgress:)]) {
        [self.delegate BJNetworkingUploadProgress:(1.0 * (float)totalBytesSent/(float)totalBytesExpectedToSend)];
    }
}

@end
