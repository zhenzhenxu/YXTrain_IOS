//
//  YXHotspotPictureCell.m
//  TrainApp
//
//  Created by 郑小龙 on 16/9/8.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXHotspotPictureCell.h"

@implementation YXHotspotPictureCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        [self layoutIfNeeded];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - layout
- (void)layoutInterfaceSingle:(BOOL)boolSingle{
    if (boolSingle) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.0f);
            make.top.equalTo(self.contentView.mas_top).offset(20.0f);
            make.right.equalTo(self.posterImageView.mas_left).offset(-15.0f);
        }];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.0f);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4.0f);
        }];
        [self.posterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-15.0f);
            make.top.equalTo(self.contentView.mas_top).offset(15.0f);
            make.width.mas_offset(105.0f);
            make.height.mas_offset(79.0f);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15.0f);
        }];
        
    }else{
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.0f);
            make.top.equalTo(self.contentView.mas_top).offset(20.0f);
            make.right.equalTo(self.posterImageView.mas_left).offset(-15.0f);
        }];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.0f);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10.0f);
        }];
        [self.posterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-15.0f);
            make.top.equalTo(self.contentView.mas_top).offset(15.0f);
            make.width.mas_offset(105.0f);
            make.height.mas_offset(79.0f);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15.0f);
        }];
    }

}
- (void)setData:(YXHotspotRequestItem_Data *)data{
    self.titleLabel.attributedText = [self contentStringWithDesc:data.title];
    self.timeLabel.text= data.timer;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:data.picUrl]];
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    if (frame.size.width > kScreenWidth - 30.0f){
        [self layoutInterfaceSingle:NO];
    }else{
        [self layoutInterfaceSingle:YES];
    }
}
- (NSMutableAttributedString *)contentStringWithDesc:(NSString *)desc{
    NSRange range = NSMakeRange(0, desc.length);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desc];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"334466"],NSParagraphStyleAttributeName:paragraphStyle} range:range];
    return attributedString;
}
@end
