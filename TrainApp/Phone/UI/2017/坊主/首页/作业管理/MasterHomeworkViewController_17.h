//
//  MasterHomeworkViewController_17.h
//  TrainApp
//
//  Created by 郑小龙 on 2017/11/20.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "PagedListViewControllerBase.h"

@interface MasterHomeworkViewController_17 : PagedListViewControllerBase
@property (nonatomic, copy) NSString *pid;//如果不传使用默认pid
@property (nonatomic ,copy) void(^requestSuccessBlock)(void);
@end
