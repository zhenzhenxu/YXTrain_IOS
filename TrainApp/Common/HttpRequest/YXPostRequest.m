//
//  YXPostRequest.m
//  YanXiuStudentApp
//
//  Created by ChenJianjun on 15/7/8.
//  Copyright (c) 2015年 yanxiu.com. All rights reserved.
//

#import "YXPostRequest.h"

@implementation YXPostRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.token = [LSTSharedInstance sharedInstance].userManger.userModel.token;
        self.ver = [YXConfigManager sharedInstance].clientVersion;
        self.os = @"ios";
    }
    return self;
}



@end
