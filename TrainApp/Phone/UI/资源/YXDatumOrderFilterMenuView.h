//
//  YXDatumOrderFilterMenuView.h
//  TrainApp
//
//  Created by 李五民 on 16/6/20.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXDatumOrderFilterMenuView : UIView

@property (nonatomic, copy) void(^didSelectedOrderCell)(NSString *condition);
@property (nonatomic, copy) void(^didSelectedFilterCell)(NSString *condition);

@end
