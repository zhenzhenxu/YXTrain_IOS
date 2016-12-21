//
//  WriteHomeworkmanager.h
//  TrainApp
//
//  Created by 郑小龙 on 16/12/20.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXChapterListRequest.h"
#import "YXWriteHomeworkRequest.h"
#import "YXCategoryListRequest.h"
#import "YXHomeworkInfoRequest.h"
typedef NS_ENUM(NSUInteger, WriteHomeworkmanagerStatus){
    WriteHomeworkmanagerStatus_Category = 0,//学段 学科 基本信息请求
    WriteHomeworkmanagerStatus_Info = 1,//作业信息请求
    WriteHomeworkmanagerStatus_ChapterList = 2//目录信息请求
};
@interface WriteHomeworkModel: NSObject
@property (nonatomic, strong) YXChapterListRequestItem *chapterList;
@property (nonatomic, strong) YXWriteHomeworkRequestItem *homeworkItem;
@property (nonatomic, strong) YXCategoryListRequestItem *listItem;
@property (nonatomic, assign) WriteHomeworkmanagerStatus managerStatus;
@end
typedef void(^WriteHomeworkmanagerBlock)(WriteHomeworkModel *model, NSError *error);

@interface WriteHomeworkManager : NSObject

- (void)requestHomework:(YXHomeworkInfoRequestItem_Body *)body CompleteBlock:(WriteHomeworkmanagerBlock)aCompleteBlock;
@end
