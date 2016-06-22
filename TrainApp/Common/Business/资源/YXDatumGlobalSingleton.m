//
//  YXDatumGlobalSingleton.m
//  YanXiuApp
//
//  Created by niuzhaowang on 15/9/6.
//  Copyright (c) 2015年 yanxiu.com. All rights reserved.
//

#import "YXDatumGlobalSingleton.h"
#import "YXDatumFilterRequest.h"
//#import "YXUserManager.h"
//#import "YXUserProfile.h"

@interface YXDatumGlobalSingleton ()

@property (nonatomic, strong) YXDatumFilterRequest *request;

@end

@implementation YXDatumGlobalSingleton

+ (YXDatumGlobalSingleton *)sharedInstance {
    NSAssert([YXDatumGlobalSingleton class] == self, @"Incorrect use of singleton : %@, %@", [YXDatumGlobalSingleton class], [self class]);
    static dispatch_once_t once;
    static YXDatumGlobalSingleton *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.myOffset = @"0";
        sharedInstance.slOffset = @"0";
    });
    
    return sharedInstance;
}

//// 获取资源筛选目录
//- (void)getDatumFilterData:(void(^)(NSError *))completion
//{
//    [self.request stopRequest];
//    self.request = [[YXDatumFilterRequest alloc]init];
//    self.request.stage = [YXUserManager sharedManager].userModel.profile.stageId;
//    @weakify(self);
//    [self.request startRequestWithDecodeClass:[YXDatumFilterRequestItem class] completion:^(id responseObject, NSError *error) {
//        @strongify(self);
//        if (!self) {
//            return;
//        }
//        if (!responseObject || error) {
//            if (completion) {
//                completion(error);
//            }
//            return;
//        }
//        YXDatumFilterRequestItem *item = responseObject;
//        self.filterModel = [YXFilterModel modelFromFilterRequestItem:item];
//        if (completion) {
//            completion(nil);
//        }
//    }];
//}

@end
