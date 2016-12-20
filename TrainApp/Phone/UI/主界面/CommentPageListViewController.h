//
//  CommentPageListViewController.h
//  TrainApp
//
//  Created by 郑小龙 on 16/11/14.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXBaseViewController.h"
#import "ActivityFirstCommentRequest.h"
#import "ActivityStepListRequest.h"
@class CommentPagedListFetcher;
@interface CommentPageListViewController : YXBaseViewController
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) CommentPagedListFetcher *dataFetcher;
@property (nonatomic, strong) NSMutableArray *dataMutableArray;
@property (nonatomic, assign) BOOL isHiddenInputView;
@property (nonatomic, strong) ActivityStepListRequestItem_Body_Active_Steps_Tools *tool;
@property (nonatomic, assign) NSInteger totalNum;

- (void)setupUI;
- (void)setupLayout;
- (void)formatCommentContent;
- (void)requestForCommentLaud:(id)comment;
- (BOOL)isCheckActivityStatus;
@end
