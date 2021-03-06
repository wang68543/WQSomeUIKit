//
//  WQVoiceCache.m
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/14.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import "WQVoiceCache.h"
#import "NSFileManager+WQPath.h"


@interface WQVoiceCache(){
    dispatch_queue_t _ioQueue;
}
@property (copy ,nonatomic) NSString *diskCachePath;
@end
@implementation WQVoiceCache
static WQVoiceCache *_instance;
+(instancetype)sharedCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithNamespace:@"WQVoiceBasicCache"];
    });
    return _instance;
}
-(instancetype)initWithNamespace:(NSString *)name{
    return [self initWithNamespace:name diskCacheDirectory:[NSFileManager pathForVoiceDirectory]];
}
-(instancetype)initWithNamespace:(NSString *)name diskCacheDirectory:(NSString *)directory{
    if(self = [self init]){
        NSString *cachePath = [directory stringByAppendingPathComponent:name];
        NSError *error = [NSFileManager createPathIfNotExtist:cachePath];
        if(error){//创建出错就使用默认路径
            self.diskCachePath = [[NSFileManager pathForVoiceDirectory] stringByAppendingPathComponent:name];
        }else{
            self.diskCachePath = cachePath;
        }
        _ioQueue = dispatch_queue_create("com.WQVoiceCache", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)storeVoice:(NSData *)voiceData forKey:(NSString *)key{
    if(voiceData){
        dispatch_async(_ioQueue, ^{
            [voiceData writeToFile:[self.diskCachePath stringByAppendingPathComponent:key] atomically:YES];
        });
       
    }
}

-(NSString *)cacheKeyForURL:(NSString *)url{
    if(!url){
        return @"";
    }
    return url.lastPathComponent;
}
-(void)queryVoiceCacheForKey:(NSString *)key done:(WQVoiceQueryCompleteBlock)doneBlock{
    NSOperation *operation = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if(operation.isCancelled)return ;
        @autoreleasepool {
            NSData *voiceData = [self diskVoiceForKey:key];
            if(voiceData){
                doneBlock(voiceData,WQVoiceCacheTypeDisk);
            }else{
                doneBlock(nil,WQVoiceCacheTypeNone);
            }
        }
    });
   
    
}
-(NSData *)diskVoiceForKey:(NSString *)key{
    return [NSData dataWithContentsOfFile:[self defaultCachePathForKey:key]];
}

-(BOOL)diskVoiceExistsWithKey:(NSString *)key{
    BOOL exists = NO;
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:key]];
    if(!exists){
       exists = [[NSFileManager defaultManager] fileExistsAtPath:[[self defaultCachePathForKey:key] stringByDeletingPathExtension]];
    }
    return exists;
}

-(NSString *)defaultCachePathForKey:(NSString *)key{
    NSLog(@"==%@",self.diskCachePath);
    return [self.diskCachePath stringByAppendingPathComponent:key];
}
- (void)dealloc{
    _ioQueue = nil;
    NSLog(@"存储工具销毁了");
}
@end
